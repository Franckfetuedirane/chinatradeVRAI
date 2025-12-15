import React from "react";

export default function Footer() {
  return (
    <footer id="contact" className="bg-white border-t mt-12">
      <div className="max-w-7xl mx-auto px-4 py-8 flex flex-col md:flex-row items-start md:items-center justify-between">
        <div>
          <div className="text-lg font-bold">
            <span className="text-orange-600">China</span>
            <span className="text-[#0B5ED7] ml-1">Trade Master</span>
          </div>
          <p className="text-sm text-gray-600 mt-1">Votre partenaire commercial fiable</p>
        </div>
        <div className="mt-4 md:mt-0 text-sm text-gray-700">
          <div>Tel: <a href="tel:+237678766464" className="text-blue-600">+237 678 76 64 64</a></div>
          <div>WhatsApp: <a href="https://wa.me/237678766464" className="text-blue-600">+237 678 76 64 64</a></div>
          <div>Email: <a href="mailto:chinatrademasterh@gmail.com" className="text-blue-600">chinatrademasterh@gmail.com</a></div>
        </div>
      </div>
      <div className="bg-gray-50 text-center py-3 text-sm text-gray-500">&copy; {new Date().getFullYear()} China Trade Master. Tous droits réservés.</div>
    </footer>
  );
}
