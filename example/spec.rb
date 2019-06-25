require 'gelauto/rspec'
require 'pry-byebug'

require_relative './image.rb'
Gelauto.paths << File.join(__dir__, 'image.rb')

describe Image do
  subject(:image) { described_class.new('foo.jpg', 800, 400) }

  it 'calculates aspect ratio correctly' do
    expect(image.aspect_ratio).to eq(2.0)
  end
end
