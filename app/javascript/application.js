// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import "chartkick/chart.js"

document.addEventListener("turbo:load", () => {
  for (const chart of Object.values(Chartkick.charts)) {
    const chartObj = chart.getChartObject();
      
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
            "percentage: " + percentage + "%"
          ];
        }
      };

      chartObj.update();
  }
});

document.addEventListener("turbo:load", () => {
  let el = ["item-affected-pie-chart-canvas","category-pie-chart-canvas"]
  el.forEach((id) => {
    const chart = Chartkick.charts[id];
    if (!chart) return;

    const chartObj = chart.getChartObject();
    const legendContainer = document.getElementById(id + "-item");
    
    const ul = document.createElement("ul");

    chartObj.data.labels.forEach((label, index) => {
      const li = document.createElement("li");

      const colorBox = document.createElement("span");
      colorBox.style.background =
        chartObj.data.datasets[0].backgroundColor[index];

      li.appendChild(colorBox);
      li.appendChild(document.createTextNode(label));

      li.onclick = () => {
        chartObj.toggleDataVisibility(index);
        chartObj.update();
      };

      ul.appendChild(li);
    });

    legendContainer.innerHTML = "";
    legendContainer.appendChild(ul);
  });
});