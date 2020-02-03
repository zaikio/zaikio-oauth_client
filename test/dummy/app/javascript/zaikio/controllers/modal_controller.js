import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['content'];

  connect() {
    // document.querySelector('#content').classList.remove('with-modal');
  }

  hide(event) {
    if (this.element === event.target) {
      window.hideModal();
    }
  }

  cancel(event) {
    event.preventDefault();
    window.hideModal();
  }
}
