
<template>
  <div>
    <div class="table-wrapper" v-if="!error">
      <table>
        <thead>
          <tr>
            <th style="width: 80px;">ID</th>
            <th>Razón social</th>
            <th>Municipio</th>
            <th>Departamento</th>
            <th>Actividades</th>
            <th style="width: 160px;">Fecha matrícula</th>
            <th>Dirección</th>
            <th>Rep. legal</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading">
            <td colspan="8">Cargando resultados...</td>
          </tr>
          <tr v-else-if="rows.length === 0">
            <td colspan="8">Sin resultados</td>
          </tr>
          <tr v-else v-for="r in rows" :key="r.id">
            <td>{{ r.id }}</td>
            <td>{{ r.razon_social }}</td>
            <td>{{ r.municipio }}</td>
            <td>{{ r.departamento }}</td>
            <td>{{ r.actividades }}</td>
            <td>{{ formatDate(r.fecha_matricula) }}</td>
            <td>{{ r.direccion_comercial }}</td>
            <td>{{ r.rep_legal }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="error" v-else>
      {{ error }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ResultsTableEmpresas',
  props: {
    rows: { type: Array, default: () => [] },
    loading: { type: Boolean, default: false },
    error: { type: String, default: '' }
  },
  methods: {
    formatDate (iso) {
      if (!iso) return ''
      try {
        const d = new Date(iso)
        return d.toLocaleDateString()
      } catch {
        return iso
      }
    }
  }
}
</script>
