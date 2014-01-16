InvestmentGraph = function(){
  function Class(target){
    this.svg = dimple.newSvg(target, 590, 400)
    this.savedData = []
  }

  Class.prototype.add = function(data){
    this.savedData = data
    this.render()
  }

  function keepN(array, n){
    var match = array.length / n
    return array.filter(function(e, i){
      return Math.floor(i % match) == 0
    })
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
