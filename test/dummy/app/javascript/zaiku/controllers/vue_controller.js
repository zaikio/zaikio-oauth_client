import { Controller } from 'stimulus';

import Vue from 'vue';
import Autocomplete from './autocomplete.vue';

const components = { autocomplete: Autocomplete };

export default class extends Controller {
  connect() {
    const el = this.element;
    const component = el.dataset.component;
    const props = JSON.parse(el.dataset.props);
    this.vue = new Vue({
      el,
      render: h => h(components[component], { props }),
    });
  }
}
