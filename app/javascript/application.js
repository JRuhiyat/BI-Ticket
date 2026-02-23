// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import "chartkick/chart.js"

document.addEventListener("turbo:load", () => {
  for (const chart of Object.values(Chartkick.charts)) {
    const chartObj = chart.getChartObject();

    if (chartObj.config.type === "pie") {
      chartObj.options.plugins.tooltip.callbacks = {
        // Remove default value line
        label: () => "",

        // Add custom footer
        footer: (tooltipItems) => {
          const data = tooltipItems[0].chart.data.datasets[0].data;
          const value = tooltipItems[0].raw;
          const total = data.reduce((a, b) => a + b, 0);
          const percentage = ((value / total) * 100).toFixed(1);

          return [
            "Total: " + total,
            "Shared: " + value,
            "Share: " + percentage + "%"
          ];
        }
      };

      chartObj.update();
    }
  }
});