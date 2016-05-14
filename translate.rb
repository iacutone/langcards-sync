class Translate

  attr_reader :translator

  def initialize
    @translator = Yandex::Translator.new()
  end
  
  def detect_source_language(word)
    translator.detect word
  end

  def translate(word)
    translator.translate word, from: detect_source_language(word), to: 'en'
  end
end
