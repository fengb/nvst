require 'spec_helper'


describe ModelsIncluded do
  module TestModule
    extend ModelsIncluded
  end

  class Admin
    include TestModule
  end

  describe '.models_included' do
    it 'is Admin only' do
      expect(TestModule.models_included).to eq([Admin])
    end
  end
end
