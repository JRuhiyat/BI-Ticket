// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import Chart from "chart.js/auto"
import ChartDataLabels from "chartjs-plugin-datalabels"
Chart.register(ChartDataLabels)
import "chartkick/chart.js"

document.addEventListener("turbo:load", () => {
  for (const chart of Object.values(Chartkick.charts)) {
    const chartObj = chart.getChartObject();

    // Enable datalabels only on pie/doughnut charts
    if (chartObj.config.type === "pie" || chartObj.config.type === "doughnut") {
      // var ctx = $("#status-pie-chart-canvas").get(0).getContext("2d");
      // ctx.width = 300;
      // ctx.height = 300;
      chartObj.options.plugins.datalabels = {
        display: "auto",
        // Place labels outside the pie slices.
        anchor: "end",
        align: "end",
        offset: 14,
        clamp: false,
        clip: false,

        color: "#fff",
        padding: 6,
        borderRadius: 4,

        backgroundColor: (ctx) => {
          const bg = ctx.dataset.backgroundColor;
          if (Array.isArray(bg)) return bg[ctx.dataIndex] || "#667eea";
          return bg || "#667eea";
        },

        formatter: (value, ctx) => {
          const chart = ctx.chart;
          if (!chart.getDataVisibility(ctx.dataIndex)) return null;

          const v = Number(value);
          if (!v) return null;

          const labels = chart.data.labels || [];
          const label = labels[ctx.dataIndex] || "";

          // Use visible slice total for percentage.
          const datasetData = ctx.dataset.data.map((x) => Number(x));
          const total = datasetData.reduce((sum, x, i) => {
            return chart.getDataVisibility(i) ? sum + x : sum;
          }, 0);
          if (!total) return null;

          const pct = (v / total) * 100;
          const pctRounded = Math.round(pct);

          // Example style: "ONE 7%"
          return `${pctRounded}%`;
        },

        font: (ctx) => {
          const chart = ctx.chart;
          const v = Number(ctx.raw);

          if (!chart.getDataVisibility(ctx.dataIndex)) return { size: 12, weight: "bold" };

          const datasetData = ctx.dataset.data.map((x) => Number(x));
          const visibleValues = datasetData.filter((x, i) => chart.getDataVisibility(i));
          if (!visibleValues.length) return { size: 12, weight: "bold" };

          const max = Math.max(...visibleValues);
          return v === max ? { size: 14, weight: "bold" } : { size: 12, weight: "bold" };
        }
      };
    }

    chartObj.options.plugins.tooltip.callbacks = {
      // Remove default value line
      label: () => "",

      // Add custom footer
      footer: (tooltipItems) => {        
        // Special case: time-series chart uses two datasets:
        // - Submitted
        // - Completed

        const chart = tooltipItems[0].chart;
        const value = tooltipItems[0].raw;
        const chartId = chart.canvas && chart.canvas.id;

        const dataIndex = tooltipItems[0].dataIndex;
        const datasets = chart.data.datasets;

        // if (chartId === "time-series-chart-canvas") {
          const submittedDs =
            datasets.find((ds) => /submitted/i.test(ds.label) || /total/i.test(ds.label)) ||
            datasets[0];
          const completedDs =
            datasets.find((ds) => /completed/i.test(ds.label)) ||
            datasets[1] ||
            datasets[0];

          const submitted = (submittedDs && submittedDs.data[dataIndex]) || 0;
          const completed = (completedDs && completedDs.data[dataIndex]) || 0;
          const completionRate = submitted ? ((completed / submitted) * 100).toFixed(1) : "0";

          return [
            "Submitted: " + submitted,
            "Completed: " + completed,
            "Completion: " + completionRate + "%"
          ];
        // }

        // const completedDs =
        //   datasets.find((ds) => /completed/i.test(ds.label) && !/not/i.test(ds.label)) ||
        //   datasets[0];
        // const notCompletedDs =
        //   datasets.find((ds) => /not/i.test(ds.label) && /completed/i.test(ds.label)) ||
        //   datasets[1];

        // const completed = (completedDs && completedDs.data[dataIndex]) || 0;
        // const notCompleted = (notCompletedDs && notCompletedDs.data[dataIndex]) || 0;
        // const total = completed + notCompleted;
        // const percentage = total ? ((value / total) * 100).toFixed(1) : "0";

        // // if (chartId === "time-series-chart-canvas") {
        // //   return [
        // //     "Completed: " + completed,
        // //     "Not Completed: " + notCompleted,
        // //     "percentage: " + percentage + "%"
        // //   ];
        // // }

        // // if (chartId === "user-locations-bar-chart-canvas") {
        // //   return [
        // //     "Completed: " + completed,
        // //     "Not Completed: " + notCompleted,
        // //     "percentage: " + percentage + "%"
        // //   ];
        // // }

        // // Default behavior: keep existing "Total / Completed" tooltip format.
        // // const data = chart.data.datasets[0].data;
        // // const total = data.reduce((a, b) => a + b, 0);
        // // const percentage = total ? ((value / total) * 100).toFixed(1) : "0";

        // return [
        //   "Total: " + total,
        //   "Completed: " + completed,
        //   "Not Completed: " + notCompleted,
        //   "percentage: " + percentage + "%"
        // ];
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