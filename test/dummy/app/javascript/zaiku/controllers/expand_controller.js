import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['trigger', 'content'];

  connect() {
    this.contentTarget.classList.add('u-is-hidden');
  }

  toggle() {
    this.contentTarget.classList.toggle('u-is-hidden');
  }

  hide(event) {
    if (this.element.contains(event.target) === false) {
      this.contentTarget.classList.add('u-is-hidden');
    }
  }
}
