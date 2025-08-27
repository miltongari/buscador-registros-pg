<template>
  <div class="col">
    <label class="muted">Buscar</label>
    <input
      class="input"
      type="text"
      :value="modelValue"
      @input="onInput"
      placeholder="Ej. ID, Razón social, Actividades...."
    />
    <div class="row" style="justify-content: flex-end;">
      <button class="btn ghost" @click="clear">Limpiar</button>
      <button class="btn primary" @click="emitSearch">Buscar</button>
    </div>
    <!-- <small class="muted">que diga algo sobre el programa</small> -->
  </div>
</template>

<script>
export default {
  name: 'SearchBar',
  props: {
    modelValue: { type: String, default: '' }
  },
  emits: ['update:modelValue', 'search', 'live'],
  methods: {
    onInput (e) {
      const val = e.target.value
      this.$emit('update:modelValue', val)
      // Emitimos evento de búsqueda en vivo para que el padre la dispare con debounce
      this.$emit('live', val)
    },
    emitSearch () {
      this.$emit('search')
    },
    clear () {
      this.$emit('update:modelValue', '')
      this.$emit('live', '')
    }
  }
}
</script>
