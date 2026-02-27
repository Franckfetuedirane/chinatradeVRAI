import React, { useEffect, useState } from "react";
import ProductCard from "./ProductCard";

const API_URL = "http://127.0.0.1:8000/api/products/";
// const API_URL = "https://chinatradevrai.onrender.com/api/products/";

export default function ProductGrid() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let mounted = true;
    setLoading(true);
    fetch(API_URL)
      .then(async (res) => {
        if (!res.ok) {
          const text = await res.text().catch(() => "");
          const err = new Error(`${res.status} ${res.statusText} ${text}`);
          err.status = res.status;
          throw err;
        }
        return res.json();
      })
      .then((data) => {
        if (!mounted) return;
        setProducts(data);
        setError(null);
      })
      .catch((err) => {
        if (!mounted) return;
        setError(err);
        setProducts([]);
      })
      .finally(() => mounted && setLoading(false));

    return () => {
      mounted = false;
    };
  }, []);

  if (loading) return <div className="text-center py-8">Chargement des produits…</div>;

  if (error) {
    if (error.status === 404) {
      return <div className="text-center text-red-600 py-8">API introuvable (404) — vérifiez que le backend tourne.</div>;
    }
    return <div className="text-center text-red-600 py-8">Erreur lors du chargement des produits : {String(error.message)}</div>;
  }

  if (!products || products.length === 0) {
    return <div className="text-center py-8 text-gray-600">Aucun produit disponible pour le moment.</div>;
  }

  return (
    <div id="products" className="grid gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
      {products.map((p) => (
        <ProductCard key={p.id} product={p} />
      ))}
    </div>
  );
}
