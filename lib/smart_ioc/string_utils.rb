module SmartIoC
  class StringUtils
    class << self
      def camelize(term)
        string = term.to_s
        string = string.sub(/^[a-z\d]*/) { |match| match.capitalize }
        string.gsub!(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }
        string.gsub!("/".freeze, "::".freeze)
        string
      end
    end
  end
end