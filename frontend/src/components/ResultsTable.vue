<template>
  <div>
    <div class="table-wrapper" v-if="!error">
      <table>
        <thead>
          <tr>
            <th style="width: 80px;">ID</th>
            <th>Título</th>
            <th>Descripción</th>
            <th style="width: 180px;">Creado</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading">
            <td colspan="4">Cargando resultados...</td>
          </tr>
          <tr v-else-if="rows.length === 0">
            <td colspan="4">No se encontraron resultados</td>
          </tr>
          <tr v-else v-for="r in rows" :key="r.id">
            <td>{{ r.id }}</td>
            <td>{{ r.title }}</td>
            <td>{{ r.description }}</td>
            <td>{{ formatDate(r.created_at) }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-else class="error">{{ error }}</div>

    <div class="pagination">
      <button class="page-btn" :disabled="page <= 1" @click="$emit('page-change', page - 1)">Anterior</button>
      <span class="page-info">Página {{ page }} de {{ totalPages }}</span>
      <button class="page-btn" :disabled="page >= totalPages" @click="$emit('page-change', page + 1)">Siguiente</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ResultsTable',
  props: {
    rows: { type: Array, default: () => [] },
    loading: { type: Boolean, default: false },
    error: { type: String, default: '' },
    page: { type: Number, default: 1 },
    pageSize: { type: Number, default: 20 },
    total: { type: Number, default: 0 }
  },
  computed: {
    totalPages () {
      return Math.max(1, Math.ceil(this.total / this.pageSize))
    }
  },
  methods: {
    formatDate (iso) {
      if (!iso) return ''
      try {
        const d = new Date(iso)
        return d.toLocaleString()
      } catch {
        return iso
      }
    }
  }
}
</script>
