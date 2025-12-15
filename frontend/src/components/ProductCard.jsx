import React from "react";

function openWhatsApp(number, name) {
  const text = encodeURIComponent(`Bonjour, je suis intéressé par le produit : ${name}`);
  // Support both international formatted or raw numbers
  const phone = number ? number.replace(/\s+/g, "") : "";
  return `https://wa.me/${phone}?text=${text}`;
}

export default function ProductCard({ product }) {
  const available = product.status === "available";
  return (
    <article className="bg-white rounded-lg shadow hover:shadow-md overflow-hidden flex flex-col">
      <div className="h-44 bg-gray-100 flex items-center justify-center overflow-hidden">
        {product.image ? (
          <img src={product.image} alt={product.name} className="object-cover w-full h-full" />
        ) : (
          <div className="text-gray-400">No image</div>
        )}
      </div>
      <div className="p-4 flex-1 flex flex-col">
        <h3 className="font-semibold text-lg mb-1">{product.name}</h3>
        <p className="text-sm text-gray-600 mb-3 flex-1">{product.description}</p>
        <div className="flex items-center justify-between mt-2">
          <span className={`text-sm font-medium ${available ? "text-green-600" : "text-red-600"}`}>
            {available ? "🟢 Disponible" : "🔴 Rupture de stock"}
          </span>
        </div>
        <div className="mt-4 flex gap-2">
          {available && (
            <>
              <a className="flex-1 inline-flex items-center justify-center gap-2 bg-[#0B5ED7] text-white px-3 py-2 rounded hover:opacity-95 transition" href={`tel:${product.phone}`}>
                📞 Appeler
              </a>
              <a className="flex-1 inline-flex items-center justify-center gap-2 bg-green-500 text-white px-3 py-2 rounded hover:opacity-95 transition" href={openWhatsApp(product.whatsapp || product.phone, product.name)} target="_blank" rel="noreferrer">
                💬 WhatsApp
              </a>
              <a className="flex-1 inline-flex items-center justify-center gap-2 bg-gray-100 text-gray-800 px-3 py-2 rounded hover:opacity-95 transition" href={`mailto:${product.email}?subject=${encodeURIComponent("Commande produit: " + product.name)}`}>
                ✉️ Email
              </a>
            </>
          )}
          {!available && (
            <div className="text-sm text-gray-500">Contactez-nous pour plus d'infos</div>
          )}
        </div>
      </div>
    </article>
  );
}
