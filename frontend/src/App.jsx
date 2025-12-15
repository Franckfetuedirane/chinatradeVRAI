import React from "react";
import Header from "./components/Header";
import Hero from "./components/Hero";
import ProductGrid from "./components/ProductGrid";
import Footer from "./components/Footer";

export default function App() {
  return (
    <div className="min-h-screen flex flex-col bg-gray-50 text-gray-900">
      <Header />
      <main className="flex-1">
        <Hero />
        <section className="max-w-7xl mx-auto px-4 py-12">
          <h2 className="text-2xl font-semibold mb-6">Nos produits</h2>
          <ProductGrid />
        </section>
      </main>
      <Footer />
    </div>
  );
}
