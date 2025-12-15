import React from "react";

export default function Hero() {
  return (
    <section className="bg-gradient-to-r from-[#0B5ED7] to-blue-500 text-white py-20">
      <div className="max-w-5xl mx-auto px-4 text-center">
        <h1 className="text-4xl md:text-5xl font-extrabold mb-4">ChinaTradeMaster</h1>
        <p className="text-lg md:text-xl mb-6">Acheter les meilleurs produits chinois et autres en toute simplicité</p>
        <a href="#products" className="inline-block bg-[#D97706] text-white px-6 py-3 rounded-md font-medium shadow hover:opacity-95 transition">Voir les produits</a>
      </div>
    </section>
  );
}
