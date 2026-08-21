/* Ejemplo del contrato de datos. Renombrar a data.js para probar.
   El archivo real se genera desde admin.html (botón "Descargar data.js"). */
window.MHV_DATA = {
  settings: {
    phone: "(555) 123-4567",
    instagram: "@mobilehomeventas"
  },
  listings: [
    {
      id: 1,
      name: "Modelo Demo",
      size: "16×76",
      type: "single",
      beds: 3,
      baths: 2,
      price: 49900,
      oldPrice: 54900,
      badge: "disp",
      location: "Lote principal",
      brand: "Clayton",
      year: 2019,
      cond: "seminueva",
      sqft: 1216,
      stock: "MH-2026-01",
      desc: "Cocina abierta y aire central. Lista para entrega.",
      descLong: "Descripción completa de ejemplo.\n\nSe muestra en la ficha de detalles.",
      features: ["Aire central", "Pisos nuevos", "Deck / porche incluido"],
      photos: []
    }
  ]
};
