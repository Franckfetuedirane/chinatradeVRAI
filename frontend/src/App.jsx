import React, { useEffect, useMemo, useState } from "react";
import "./styles.css";
import fallbackLogo from "./assets/foesa-logo.png";

const COUNTRY_CITY_MAP = {
  Cameroun: [
    "Douala",
    "Yaounde",
    "Bafoussam",
    "Bamenda",
    "Garoua",
    "Maroua",
    "Ngaoundere",
    "Bertoua",
    "Ebolowa",
    "Kribi",
    "Lembe",
    "Dschang",
    "Kumba",
    "Buea",
    "Edea",
    "Nkongsamba",
  ],
  Gabon: ["Libreville", "Port-Gentil", "Franceville", "Oyem"],
  Congo: ["Brazzaville", "Pointe-Noire", "Dolisie"],
  Tchad: ["N'Djamena", "Moundou", "Sarh"],
  France: ["Paris", "Lyon", "Marseille", "Toulouse"],
};

const DEFAULT_API_BASE = import.meta.env.DEV
  ? "http://127.0.0.1:8000"
  : "https://alluring-art-production-5c03.up.railway.app";
const RAW_API_URL = import.meta.env.VITE_API_URL || DEFAULT_API_BASE;
const API_BASE = RAW_API_URL.replace(/\/+$/, "").replace(/\/api\/products$/, "");
const PRODUCTS_URL = `${API_BASE}/api/products/`;
const AUTH_BASE = `${API_BASE}/api/auth`;

const CART_KEY = "foesa_cart_v1";

function money(value) {
  const num = Number(value || 0);
  return `${new Intl.NumberFormat("fr-FR", { maximumFractionDigits: 0 }).format(num)} XAF`;
}

function getCookie(name) {
  const escaped = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const match = document.cookie.match(new RegExp(`(?:^|; )${escaped}=([^;]*)`));
  return match ? decodeURIComponent(match[1]) : "";
}

async function parseJsonResponse(response) {
  const payload = await response.json().catch(() => ({}));
  if (!response.ok) {
    const detail = payload.detail || `Erreur ${response.status}`;
    throw new Error(detail);
  }
  return payload;
}

function normalizeProduct(p) {
  const gallery = Array.isArray(p.gallery_images) ? p.gallery_images.filter(Boolean) : [];
  const image = p.image || "";
  return {
    ...p,
    category: p.category || "General",
    category_slug: p.category_slug || "general",
    price: Number(p.price || 0),
    country: p.country || "Cameroun",
    city: p.city || "",
    gallery_images: image ? [image, ...gallery.filter((g) => g !== image)] : gallery,
    video_url: p.video_url || "",
  };
}

function ProductCard({ product, onAdd, onOpen }) {
  const thumb = product.gallery_images[0] || "";
  return (
    <article className="card">
      <button className="media-btn" onClick={() => onOpen(product)} type="button">
        {thumb ? <img src={thumb} alt={product.name} className="media" /> : <div className="media empty">No image</div>}
      </button>
      <div className="card-body">
        <span className="tag">{product.category}</span>
        <h3>{product.name}</h3>
        <p className="desc">{product.description || "Description non disponible."}</p>
        <div className="meta">
          <span>{money(product.price)}</span>
          <span>{product.country} {product.city ? `- ${product.city}` : ""}</span>
        </div>
        <div className="row-actions">
          <button className="btn light" onClick={() => onOpen(product)} type="button">Voir</button>
          <button className="btn" onClick={() => onAdd(product)} type="button">Ajouter</button>
        </div>
      </div>
    </article>
  );
}

function ProductDetail({ product, onBack, onAdd }) {
  const [active, setActive] = useState(0);
  const gallery = product.gallery_images.length ? product.gallery_images : [""];

  useEffect(() => {
    setActive(0);
  }, [product.id]);

  return (
    <section className="detail">
      <div className="detail-head">
        <button className="btn light" onClick={onBack} type="button">Retour catalogue</button>
        <button className="btn" onClick={() => onAdd(product)} type="button">Ajouter au panier</button>
      </div>
      <div className="detail-grid">
        <div>
          {gallery[active] ? <img src={gallery[active]} alt={product.name} className="detail-main" /> : <div className="detail-main empty">No image</div>}
          <div className="thumbs">
            {gallery.map((g, i) => (
              <button key={`${g}-${i}`} className={`thumb-btn ${i === active ? "is-active" : ""}`} onClick={() => setActive(i)} type="button">
                {g ? <img src={g} alt={`${product.name}-${i + 1}`} /> : <span>No</span>}
              </button>
            ))}
          </div>
          {product.video_url && (
            <video controls className="detail-video">
              <source src={product.video_url} />
            </video>
          )}
        </div>
        <div className="panel">
          <h2>{product.name}</h2>
          <p className="price">{money(product.price)}</p>
          <p>{product.description || "Aucune description."}</p>
          <ul className="specs">
            <li><strong>Categorie:</strong> {product.category}</li>
            <li><strong>Pays:</strong> {product.country}</li>
            <li><strong>Ville:</strong> {product.city || "Non renseignee"}</li>
            <li><strong>Statut:</strong> {product.status === "available" ? "Disponible" : "Rupture"}</li>
          </ul>
        </div>
      </div>
    </section>
  );
}

function CartPage({ cart, onQty, onRemove, onBack }) {
  const total = cart.reduce((acc, item) => acc + item.product.price * item.qty, 0);
  const [country, setCountry] = useState("Cameroun");
  const [city, setCity] = useState("");
  const [fullCountry, setFullCountry] = useState("");

  const knownCountries = Object.keys(COUNTRY_CITY_MAP);
  const selectedCountry = country === "Autre" ? fullCountry : country;
  const cities = COUNTRY_CITY_MAP[selectedCountry] || [];

  useEffect(() => {
    setCity("");
  }, [selectedCountry]);

  return (
    <section className="panel cart-shell">
      <div className="detail-head">
        <button className="btn light" onClick={onBack} type="button">Continuer les achats</button>
      </div>
      <h2>Panier d'achat</h2>

      <div className="shipping-grid">
        <div>
          <label>Pays de livraison</label>
          <select value={country} onChange={(e) => setCountry(e.target.value)}>
            {knownCountries.map((c) => (
              <option key={c} value={c}>{c}</option>
            ))}
            <option value="Autre">Autre pays</option>
          </select>
          {country === "Autre" && (
            <input value={fullCountry} onChange={(e) => setFullCountry(e.target.value)} placeholder="Entrer le pays" style={{ marginTop: 8 }} />
          )}
        </div>
        <div>
          <label>Ville de livraison</label>
          <select value={city} onChange={(e) => setCity(e.target.value)} disabled={!cities.length}>
            <option value="">Selectionner une ville</option>
            {cities.map((c) => (
              <option key={c} value={c}>{c}</option>
            ))}
          </select>
          {!cities.length && <div className="muted" style={{ marginTop: 8 }}>Aucune liste predefinie pour ce pays.</div>}
        </div>
      </div>

      {!cart.length && <p className="muted">Votre panier est vide.</p>}
      {cart.map((item) => (
        <div key={item.product.id} className="cart-item">
          <div>
            <strong>{item.product.name}</strong>
            <div className="muted">{money(item.product.price)}</div>
          </div>
          <div className="cart-actions">
            <button className="btn light" onClick={() => onQty(item.product.id, item.qty - 1)} type="button">-</button>
            <span>{item.qty}</span>
            <button className="btn light" onClick={() => onQty(item.product.id, item.qty + 1)} type="button">+</button>
            <button className="btn danger" onClick={() => onRemove(item.product.id)} type="button">Retirer</button>
          </div>
        </div>
      ))}
      <div className="cart-total">Total: {money(total)}</div>
    </section>
  );
}

function AuthPanel({
  mode,
  setMode,
  authError,
  onLoginSubmit,
  onRegisterSubmit,
  loginForm,
  setLoginForm,
  registerForm,
  setRegisterForm,
  authBusy,
}) {
  return (
    <section className="auth-wrap">
      <div className="panel auth-card">
        <div className="auth-tabs">
          <button className={`btn ${mode === "login" ? "" : "light"}`} onClick={() => setMode("login")} type="button">Connexion</button>
          <button className={`btn ${mode === "register" ? "" : "light"}`} onClick={() => setMode("register")} type="button">Inscription</button>
        </div>

        {authError && <p className="error">{authError}</p>}

        {mode === "login" && (
          <form className="auth-form" onSubmit={onLoginSubmit}>
            <label>Email ou username</label>
            <input
              type="text"
              autoComplete="username"
              value={loginForm.identity}
              onChange={(e) => setLoginForm((prev) => ({ ...prev, identity: e.target.value }))}
              required
            />
            <label>Mot de passe</label>
            <input
              type="password"
              autoComplete="current-password"
              value={loginForm.password}
              onChange={(e) => setLoginForm((prev) => ({ ...prev, password: e.target.value }))}
              required
            />
            <button className="btn" type="submit" disabled={authBusy}>
              {authBusy ? "Connexion..." : "Se connecter"}
            </button>
          </form>
        )}

        {mode === "register" && (
          <form className="auth-form" onSubmit={onRegisterSubmit}>
            <label>Prenom</label>
            <input
              type="text"
              autoComplete="given-name"
              value={registerForm.first_name}
              onChange={(e) => setRegisterForm((prev) => ({ ...prev, first_name: e.target.value }))}
            />
            <label>Nom</label>
            <input
              type="text"
              autoComplete="family-name"
              value={registerForm.last_name}
              onChange={(e) => setRegisterForm((prev) => ({ ...prev, last_name: e.target.value }))}
            />
            <label>Email</label>
            <input
              type="email"
              autoComplete="email"
              value={registerForm.email}
              onChange={(e) => setRegisterForm((prev) => ({ ...prev, email: e.target.value }))}
              required
            />
            <label>Nom d'utilisateur</label>
            <input
              type="text"
              autoComplete="username"
              value={registerForm.username}
              onChange={(e) => setRegisterForm((prev) => ({ ...prev, username: e.target.value }))}
              required
            />
            <label>Mot de passe</label>
            <input
              type="password"
              autoComplete="new-password"
              value={registerForm.password}
              onChange={(e) => setRegisterForm((prev) => ({ ...prev, password: e.target.value }))}
              minLength={8}
              required
            />
            <button className="btn" type="submit" disabled={authBusy}>
              {authBusy ? "Inscription..." : "Creer mon compte"}
            </button>
          </form>
        )}
      </div>
    </section>
  );
}

export default function App() {
  const [products, setProducts] = useState([]);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [query, setQuery] = useState("");
  const [category, setCategory] = useState("");
  const [country, setCountry] = useState("Cameroun");
  const [city, setCity] = useState("");
  const [page, setPage] = useState("catalog");
  const [selected, setSelected] = useState(null);
  const [cart, setCart] = useState(() => {
    try {
      const raw = localStorage.getItem(CART_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  });

  const [authLoading, setAuthLoading] = useState(true);
  const [authBusy, setAuthBusy] = useState(false);
  const [authError, setAuthError] = useState("");
  const [authMode, setAuthMode] = useState("login");
  const [user, setUser] = useState(null);
  const [loginForm, setLoginForm] = useState({ identity: "", password: "" });
  const [registerForm, setRegisterForm] = useState({
    first_name: "",
    last_name: "",
    email: "",
    username: "",
    password: "",
  });
  const FOESA_LOGO_URL = `${API_BASE}/static/products/img/foesa-logo.png`;

  useEffect(() => {
    localStorage.setItem(CART_KEY, JSON.stringify(cart));
  }, [cart]);

  useEffect(() => {
    let isMounted = true;

    async function bootstrapAuth() {
      try {
        await fetch(`${AUTH_BASE}/csrf/`, { credentials: "include" });
        const meRes = await fetch(`${AUTH_BASE}/me/`, { credentials: "include" });
        const mePayload = await parseJsonResponse(meRes);
        if (!isMounted) return;
        setUser(mePayload.authenticated ? mePayload.user : null);
      } catch {
        if (!isMounted) return;
        setUser(null);
      } finally {
        isMounted && setAuthLoading(false);
      }
    }

    bootstrapAuth();
    return () => {
      isMounted = false;
    };
  }, []);

  useEffect(() => {
    let isMounted = true;
    if (!user) {
      setProducts([]);
      setLoading(false);
      return () => {
        isMounted = false;
      };
    }

    async function loadProducts() {
      setLoading(true);
      try {
        const r = await fetch(PRODUCTS_URL, { credentials: "include" });
        if (!r.ok) throw new Error(`Erreur API ${r.status}`);
        const data = await r.json();
        if (!isMounted) return;
        setProducts((data || []).map(normalizeProduct));
        setError("");
      } catch (err) {
        if (!isMounted) return;
        setProducts([]);
        setError(`Impossible de joindre l'API (${PRODUCTS_URL}). Verifie la configuration backend.`);
      } finally {
        isMounted && setLoading(false);
      }
    }

    loadProducts();
    return () => {
      isMounted = false;
    };
  }, [user]);

  const allCountries = useMemo(() => {
    const values = new Set(["Cameroun"]);
    products.forEach((p) => p.country && values.add(p.country));
    return Array.from(values).sort();
  }, [products]);

  const allCities = useMemo(() => {
    const values = new Set(COUNTRY_CITY_MAP[country] || []);
    products.forEach((p) => {
      if (!country || p.country.toLowerCase() === country.toLowerCase()) {
        p.city && values.add(p.city);
      }
    });
    return Array.from(values).sort((a, b) => a.localeCompare(b));
  }, [products, country]);

  const allCategories = useMemo(() => {
    const values = new Set(products.map((p) => p.category || "General"));
    return Array.from(values).sort((a, b) => a.localeCompare(b));
  }, [products]);

  const filtered = useMemo(() => {
    const term = query.trim().toLowerCase();
    return products.filter((p) => {
      const byTerm = !term || [p.name, p.description, p.city, p.country, p.category].join(" ").toLowerCase().includes(term);
      const byCountry = !country || p.country.toLowerCase() === country.toLowerCase();
      const byCity = !city || p.city.toLowerCase().includes(city.toLowerCase());
      const byCategory = !category || p.category.toLowerCase() === category.toLowerCase();
      return byTerm && byCountry && byCity && byCategory;
    });
  }, [products, query, country, city, category]);

  const cartCount = cart.reduce((acc, item) => acc + item.qty, 0);

  async function authPost(path, payload) {
    const csrfToken = getCookie("csrftoken");
    const response = await fetch(`${AUTH_BASE}/${path}/`, {
      method: "POST",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        "X-CSRFToken": csrfToken,
      },
      body: JSON.stringify(payload || {}),
    });
    return parseJsonResponse(response);
  }

  async function onLoginSubmit(event) {
    event.preventDefault();
    setAuthBusy(true);
    setAuthError("");
    try {
      const payload = await authPost("login", {
        username: loginForm.identity,
        password: loginForm.password,
      });
      setUser(payload.user);
      setLoginForm({ identity: "", password: "" });
    } catch (err) {
      setAuthError(err.message);
    } finally {
      setAuthBusy(false);
    }
  }

  async function onRegisterSubmit(event) {
    event.preventDefault();
    setAuthBusy(true);
    setAuthError("");
    try {
      const payload = await authPost("register", registerForm);
      setUser(payload.user);
      setRegisterForm({
        first_name: "",
        last_name: "",
        email: "",
        username: "",
        password: "",
      });
    } catch (err) {
      setAuthError(err.message);
    } finally {
      setAuthBusy(false);
    }
  }

  async function onLogout() {
    try {
      await authPost("logout", {});
    } catch {
      // no-op
    }
    setUser(null);
    setSelected(null);
    setPage("catalog");
  }

  function addToCart(product) {
    setCart((prev) => {
      const exists = prev.find((it) => it.product.id === product.id);
      if (exists) return prev.map((it) => (it.product.id === product.id ? { ...it, qty: it.qty + 1 } : it));
      return [...prev, { product, qty: 1 }];
    });
  }

  function setQty(productId, qty) {
    if (qty <= 0) {
      setCart((prev) => prev.filter((it) => it.product.id !== productId));
      return;
    }
    setCart((prev) => prev.map((it) => (it.product.id === productId ? { ...it, qty } : it)));
  }

  function removeItem(productId) {
    setCart((prev) => prev.filter((it) => it.product.id !== productId));
  }

  return (
    <div className="app">
      <header className="top">
        <div className="brand">
          <img src={FOESA_LOGO_URL} alt="FOESA" onError={(e) => { e.currentTarget.onerror = null; e.currentTarget.src = fallbackLogo; }} />
          <div>
            <h1>FOESA</h1>
            <p>Marketplace produits - Cameroun</p>
          </div>
        </div>
        <div className="actions">
          {user && (
            <>
              <button className={`btn light ${page === "catalog" ? "is-active" : ""}`} onClick={() => { setPage("catalog"); setSelected(null); }} type="button">Catalogue</button>
              <button
                className={`cart-btn ${page === "cart" ? "is-active" : ""}`}
                onClick={() => setPage("cart")}
                type="button"
                aria-label="Ouvrir le chariot"
                title="Chariot"
              >
                <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                  <path d="M3 4h2l2.2 10.2a2 2 0 0 0 2 1.6h7.9a2 2 0 0 0 2-1.5L22 7H7.1" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
                  <circle cx="10" cy="20" r="1.6" fill="currentColor" />
                  <circle cx="18" cy="20" r="1.6" fill="currentColor" />
                </svg>
                <span className="cart-count">{cartCount}</span>
              </button>
            </>
          )}
          {user ? (
            <button className="btn light" type="button" onClick={onLogout}>Deconnexion</button>
          ) : null}
        </div>
      </header>

      <main className="content catalog-shell">
        {authLoading && <div className="panel">Verification de la session...</div>}

        {!authLoading && !user && (
          <AuthPanel
            mode={authMode}
            setMode={setAuthMode}
            authError={authError}
            onLoginSubmit={onLoginSubmit}
            onRegisterSubmit={onRegisterSubmit}
            loginForm={loginForm}
            setLoginForm={setLoginForm}
            registerForm={registerForm}
            setRegisterForm={setRegisterForm}
            authBusy={authBusy}
          />
        )}

        {!authLoading && user && (
          <>
            {page === "catalog" && !selected && (
              <section className="panel filters">
                <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Rechercher un produit, une ville, un pays..." />
                <select value={category} onChange={(e) => setCategory(e.target.value)}>
                  <option value="">Toutes categories</option>
                  {allCategories.map((c) => <option key={c} value={c}>{c}</option>)}
                </select>
                <select value={country} onChange={(e) => { setCountry(e.target.value); setCity(""); }}>
                  <option value="">Tous pays</option>
                  {allCountries.map((c) => <option key={c} value={c}>{c}</option>)}
                </select>
                <input list="cities" value={city} onChange={(e) => setCity(e.target.value)} placeholder="Ville" />
                <datalist id="cities">
                  {allCities.map((c) => <option key={c} value={c} />)}
                </datalist>
              </section>
            )}

            {loading && <div className="panel">Chargement...</div>}
            {error && !loading && <div className="panel error">Erreur: {error}</div>}

            {!loading && !error && page === "catalog" && !selected && (
              <>
                <div className="result-head">{filtered.length} produit(s) trouves</div>
                <section className="grid">
                  {filtered.map((p) => (
                    <ProductCard key={p.id} product={p} onAdd={addToCart} onOpen={(product) => { setSelected(product); setPage("catalog"); }} />
                  ))}
                </section>
              </>
            )}

            {!loading && !error && page === "catalog" && selected && (
              <ProductDetail product={selected} onBack={() => setSelected(null)} onAdd={addToCart} />
            )}

            {page === "cart" && <CartPage cart={cart} onQty={setQty} onRemove={removeItem} onBack={() => setPage("catalog")} />}
          </>
        )}
      </main>
    </div>
  );
}
