<template>
  <button
    class="btn secondary"
    @click="exportExcel"
    :disabled="rows.length === 0"
  >
    Exportar a Excel
  </button>
</template>

<script>
// Exportación en el cliente con SheetJS
import * as XLSX from "xlsx";

export default {
  name: "ExportButton",
  props: {
    rows: { type: Array, default: () => [] },
  },
  methods: {
    exportExcel() {
      try {
        // 1) Convertimos los datos a worksheet
        const normalized = this.rows.map((r) => ({
          ID: r.id,
          "Razón social": r.razon_social,
          Municipio: r.municipio,
          Departamento: r.departamento,
          Actividades: r.actividades,
          "Dirección comercial": r.direccion_comercial,
          "Fecha matrícula": r.fecha_matricula
            ? new Date(r.fecha_matricula).toLocaleDateString()
            : "",
          // "Fecha matrícula": r.fecha_matricula,
          "Representante legal": r.rep_legal,
        }));
        const ws = XLSX.utils.json_to_sheet(normalized);

        // 2) Creamos el libro y añadimos la hoja
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Resultados");

        // 3) Guardamos el archivo
        XLSX.writeFile(wb, "resultados.xlsx");
      } catch (err) {
        console.error(err);
        alert("No se pudo exportar a Excel.");
      }
    },
  },
};
</script>
