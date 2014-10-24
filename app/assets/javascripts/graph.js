Mutiny.widgets.graph = {
  defaults: { width: 900, height: 500 },
  init: function(instigator, options){
    d3.json(options.url, function(error, data) {
      if (error) return console.warn(error);

      var svg = dimple.newSvg(instigator, options.width, options.height)
      var chart = new dimple.chart(svg, data)
      chart.setBounds(-1, 0, options.width + 1, options.height)
      chart.addCategoryAxis('x', options.xAxis)
      chart.addMeasureAxis('y', options.yAxis)
      chart.addSeries(options.series, dimple.plot.line)
      chart.draw()
    })
  }
}
