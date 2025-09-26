import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "text" ]

  connect() {
    this.reviews = JSON.parse(this.data.get("reviews"));
    this.current = 0;
    // Use Stimulus target, do not override it
    this.show();
    this.startInterval();
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval);
  }

  show() {
    this.textTarget.textContent = this.reviews[this.current];
  }

  prev() {
    this.current = (this.current + this.reviews.length - 1) % this.reviews.length;
    this.show();
    this.resetInterval();
  }

  next() {
    this.current = (this.current + 1) % this.reviews.length;
    this.show();
    this.resetInterval();
  }

  startInterval() {
    this.interval = setInterval(() => {
      this.next();
    }, 3500);
  }

  resetInterval() {
    if (this.interval) clearInterval(this.interval);
    this.startInterval();
  }
}
