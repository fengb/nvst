module ApplicationHelper
  def j(jsonable)
    jsonable.to_json
  end
end
