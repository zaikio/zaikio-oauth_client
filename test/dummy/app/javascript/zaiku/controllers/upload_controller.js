import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'fileName',
    'uploadIcon',
    'uploadInfo',
    'saveIcon',
    'saveInfo',
  ];

  updateFieldUI(event) {
    const file =
      event.type === 'drop'
        ? event.dataTransfer.files[0]
        : event.target.files[0];

    this.fileNameTarget.textContent = file.name;

    if (file) {
      this.saveIconTarget.classList.remove('u-is-hidden');
      this.saveInfoTarget.classList.remove('u-is-hidden');
      this.uploadIconTarget.classList.add('u-is-hidden');
      this.uploadInfoTarget.classList.add('u-is-hidden');
    } else {
      this.saveIconTarget.classList.add('u-is-hidden');
      this.saveInfoTarget.classList.add('u-is-hidden');
      this.uploadIconTarget.classList.remove('u-is-hidden');
      this.uploadInfoTarget.classList.remove('u-is-hidden');
    }
  }
}
