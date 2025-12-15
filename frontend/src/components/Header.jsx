import React from "react";

export default function Header() {
  return (
    <header className="bg-white shadow">
      <div className="max-w-7xl mx-auto px-4 py-4 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="text-2xl font-bold">
            <span className="text-orange-600">China</span>
            <span className="text-[#0B5ED7]">TradeMaster</span>
          </span>
        </div>
        <nav className="hidden md:flex gap-6 text-sm items-center">
          <a href="#products" className="hover:underline font-medium">
            Produits
          </a>
          <a href="#contact" className="hover:underline, font-medium">
            Contact
          </a>
        </nav>
      </div>
    </header>
  );
}
