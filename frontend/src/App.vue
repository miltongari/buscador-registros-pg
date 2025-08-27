
<template>
  <div class="container">
    <div class="panel header">
      <h1 style="text-align: center; font-size: 60px;">🔍Buscador De Registros🔍</h1>
    </div>

    <div class="grid">
      <!-- Columna izquierda: filtros y acciones -->
      <div class="panel col">
        <SearchBar
          :modelValue="query"
          @update:modelValue="val => query = val"
          @search="searchNow"
          @live="handleLive" />

        <div class="row" style="gap: .5rem; align-items:center; margin-top: .5rem;">
          <label class="muted">Resultados por página</label>
          <select class="input" v-model.number="pageSize" @change="searchNow">
            <option :value="5">5</option>
            <option :value="10">10</option>
            <option :value="20">20</option>
            <option :value="50">50</option>
            <option :value="100">100</option>
          </select>
        </div>

        <ExportButton :rows="rows" />
      </div>

      <!-- Columna derecha: resultados -->
      <div class="panel">
        <ResultsTableEmpresas :rows="rows" :loading="loading" :error="error" />

        <!-- Paginación -->
        <div class="row" style="justify-content: center; gap: .5rem; margin-top: .5rem;">
          <button class="btn" :disabled="page === 1 || loading" @click="changePage(page - 1)">«</button>
          <span>Página {{ page }} de {{ totalPages }}</span>
          <button class="btn" :disabled="page === totalPages || loading" @click="changePage(page + 1)">»</button>
        </div>
        <small class="muted">{{ total }} resultados</small>
      </div>
    </div>
  </div>
</template>

<script>
import debounce from './utils/debounce'
import api from './services/api'
import SearchBar from './components/SearchBar.vue'
import ResultsTableEmpresas from './components/ResultsTableEmpresas.vue'
import ExportButton from './components/ExportButton.vue'

export default {
  name: 'App',
  components: { SearchBar, ResultsTableEmpresas, ExportButton },
  data () {
    return {
      query: '',
      page: 1,
      pageSize: 100,
      total: 0,
      rows: [],
      loading: false,
      error: ''
    }
  },
  created () {
    this.searchNow()
  },
  computed: {
    totalPages () {
      return Math.max(1, Math.ceil(this.total / this.pageSize))
    }
  },
  methods: {
    async fetchResults () {
      this.loading = true
      this.error = ''
      try {
        const params = {
          q: this.query,
          page: this.page,
          limit: this.pageSize
        }
        const { data } = await api.get('/empresas', { params })
        if (data?.ok) {
          this.rows = data.rows || []
          this.total = data.total || 0
        } else {
          this.rows = []
          this.total = 0
        }
      } catch (err) {
        console.error(err)
        this.error = 'No se pudieron cargar los datos.'
        this.rows = []
        this.total = 0
      } finally {
        this.loading = false
      }
    },
    searchNow () {
      this.page = 1
      this.fetchResults()
    },
    changePage (newPage) {
      if (newPage === this.page) return
      this.page = newPage
      this.fetchResults()
    },
    handleLive: debounce(function (val) {
      this.query = val
      this.page = 1
      this.fetchResults()
    }, 400)
  }
}
</script>
