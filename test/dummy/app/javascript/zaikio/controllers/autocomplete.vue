<template>
  <div class="v-autocomplete">
    <input type="hidden" :value="value" :name="name" />
    <input
      ref="input"
      type="text"
      v-model="search"
      :placeholder="placeholder"
      :tabindex="tabindex"
      :autofocus="autofocus"
      @input="onChange"
      @focus="onFocus(true)"
      @blur="onFocus(false)"
      @keydown="onKeypress"
    />
    <div class="v-autocomplete__results" v-if="open">
      <div
        class="v-autocomplete__result"
        v-for="(result, index) in results"
        :key="result[attribute]"
        :class="{'is-selected': index === selectedIndex}"
        @click="onSelect(result[attribute], result.name)"
        @mouseenter="selectedIndex = index"
      >
        <span>{{result.name}}</span>
        <span class="v-autocomplete__description" v-if="result.description">{{result.description}}</span>
      </div>
    </div>
  </div>
</template>

<script>
import { axios } from '../common/axios';
import { setTimeout } from 'timers';
import Rails from '@rails/ujs';

export default {
  props: {
    url: { type: String, required: true },
    name: { type: String, required: true },
    initialValue: String,
    label: String,
    submit: { type: Boolean, required: true },
    attribute: { type: String, default: 'id' },
    autofocus: Boolean,
    placeholder: String,
    tabindex: Number,
  },
  data: function(init) {
    return {
      value: this.initialValue,
      search: this.label,
      results: [],
      open: false,
      selectedIndex: undefined,
    };
  },

  methods: {
    async onChange() {
      this.selectedIndex = undefined;
      this.value = undefined;
      if (this.search.length < 1) {
        this.results = [];
      } else {
        const response = await axios.get(this.url, {
          params: { term: this.search },
        });
        this.results = response.data;
      }
    },

    onKeypress(event) {
      if (event.key === 'ArrowDown') {
        event.preventDefault();
        if (this.selectedIndex === undefined) {
          this.selectedIndex = 0;
        } else if (this.selectedIndex < this.results.length + 1) {
          this.selectedIndex = (this.selectedIndex || 0) + 1;
        }
      } else if (event.key === 'ArrowUp') {
        event.preventDefault();
        if (this.selectedIndex && this.selectedIndex > 0) {
          this.selectedIndex = (this.selectedIndex || 0) - 1;
        }
      } else if (event.key === 'Enter') {
        event.preventDefault();
        if (this.selectedIndex !== undefined) {
          const result = this.results[this.selectedIndex];
          if (result) {
            this.onSelect(result[this.attribute], result.name);
            event.currentTarget.blur();
          }
        }
      }
    },

    onSelect(id, name) {
      this.value = id;
      this.search = name;
      this.open = false;
      if (this.submit) {
        const form = this.$refs.input.form;
        setTimeout(() => Rails.fire(form, 'submit'), 10); // give vue the chance to render this before turbolinks takes over
      }
    },

    onFocus(open) {
      if (open) {
        this.open = open;
      } else {
        setTimeout(() => (this.open = false), 100);
      }
    },
  },
};
</script>