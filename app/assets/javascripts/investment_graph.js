InvestmentGraph = function(){
  function Class(target){
    this.svg = dimple.newSvg(target, 590, 400)
    this.savedData = []
  }

  Class.prototype.add = function(data){
    this.savedData = data
    this.render()
  }

  function everyNth(array, n, offset){
    offset = offset || 0
    return array.filter(function(e, i){
      return Math.floor((i + offset) % n) == 0
    })
  }

  function keepN(array, n, offset){
    return everyNth(array, array.length / n, offset)
  }

  Class.prototype.render = function(){
    var chart = new dimple.chart(this.svg, keepN(this.savedData, 200))
    chart.setBounds(60, 30, 505, 305)
    chart.addCategoryAxis('x', 'date').addOrderRule('Date')
    chart.addMeasureAxis('y', 'adjusted_price')
    chart.addSeries('investment', dimple.plot.line)
    chart.draw();
    return this;
  }

  return Class
}()
