# frozen_string_literal: true

require 'spec_helper'

describe Gelauto do
  before { index.reset }

  let(:index) { Gelauto.method_index }

  context 'with simple types' do
    it 'identifies method signatures correctly' do
      img = nil

      Gelauto.discover do
        img = GelautoSpecs::Image.new('foo.jpg', 800, 400)
        expect(img.aspect_ratio).to eq(2.0)
      end

      init = get_indexed_method(img, :initialize)
      expect(init).to accept(path: String, width: Integer, height: Integer)
      expect(init).to hand_back_void

      aspect_ratio = get_indexed_method(img, :aspect_ratio)
      expect(aspect_ratio).to hand_back(Float)
    end
  end

  context 'with Sorbet generic types' do
    it 'uses T.nilable with T.any correctly' do
      Gelauto.discover do
        GelautoSpecs::Utility.safe_to_string(nil)
        GelautoSpecs::Utility.safe_to_string(1.0)
        GelautoSpecs::Utility.safe_to_string(2)
      end

      safe_to_string = get_indexed_method(GelautoSpecs::Utility, :safe_to_string)
      expect(safe_to_string.to_sig).to include('input: T.nilable(T.any(Float, Integer))')
      expect(safe_to_string.to_sig).to include('returns(String')
    end

    it 'uses T.Hash and T::Array with T.untyped correctly' do
      Gelauto.discover do
        GelautoSpecs::Utility.safe_get_keys({})
      end

      safe_get_keys = get_indexed_method(GelautoSpecs::Utility, :safe_get_keys)
      expect(safe_get_keys.to_sig).to include('input: T::Hash[T.untyped, T.untyped]')
      expect(safe_get_keys.to_sig).to include('returns(T::Array[T.untyped])')
    end
  end

  context 'with generic types' do
    before do
      Gelauto.discover do
        @client = GelautoSpecs::Client.new(url: 'http://foo.com', username: 'bar')
        @response = @client.request('body', param1: 'abc', param2: 'def')
        expect(@response.to_a).to eq([200, 'it worked!'])
      end
    end

    it 'identifies signature for Client#initialize' do
      init = get_indexed_method(@client, :initialize)
      expect(init).to accept(options: { Hash => { key: Symbol, value: String } })
      expect(init).to hand_back_void
    end

    it 'identifies signature for Client#request' do
      request = get_indexed_method(@client, :request)
      expect(request).to accept(body: String, headers: { Hash => { key: Symbol, value: String } })
      expect(request).to hand_back(GelautoSpecs::Response)
    end

    it 'identifies signature for Response#initialize' do
      init = get_indexed_method(@response, :initialize)
      expect(init).to accept(status: Integer, body: String)
      expect(init).to hand_back_void
    end

    it 'identifies signature for Response#to_a' do
      to_a = get_indexed_method(@response, :to_a)
      expect(to_a).to hand_back(Array => { elem: [Integer, String] })
    end
  end

  context 'with nested generic types' do
    before do
      Gelauto.discover do
        GelautoSpecs::System.configure(YAML.load_file('spec/support/config.yml'))
      end
    end

    it 'identifies signatures for System.configure' do
      configure = get_indexed_method(GelautoSpecs::System, :configure)
      expect(configure).to accept(
        config: {
          Hash => {
            key: String,
            value: [
              {
                Array => {
                  elem: [
                    String,
                    {
                      Hash => {
                        key: String,
                        value: {
                          Hash => {
                            key: String,
                            value: [
                              String,
                              {
                                Array => {
                                  elem: String
                                }
                              }
                            ]
                          }
                        }
                      }
                    }
                  ]
                }
              }
            ]
          }
        }
      )
    end
  end
end
