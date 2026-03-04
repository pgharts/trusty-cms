module TrustyCms
  class StyleError < StandardError; end
  class TransformationError < StandardError; end

  class Geometry
    attr_reader :width, :height, :modifier

    def self.parse(value)
      return value if value.is_a?(Geometry)
      match = value.to_s.strip.match(/\A(\d*)x(\d*)([%<>#^!@])?\z/)
      raise StyleError, "Unrecognized geometry: #{value.inspect}" unless match

      width = match[1].to_s.empty? ? 0 : match[1].to_i
      height = match[2].to_s.empty? ? 0 : match[2].to_i
      modifier = match[3]
      new(width, height, modifier)
    end

    def initialize(width, height = nil, modifier = nil)
      @width = width.to_i
      @height = height.to_i
      @modifier = modifier
    end

    def without_modifier
      Geometry.new(width, height)
    end

    def transformed_by(other)
      other = Geometry.parse(other)
      return other.without_modifier if self =~ other || ['#', '!', '^'].include?(other.modifier)
      raise TransformationError, "geometry is not transformable without both width and height" if height == 0 || width == 0

      case other.modifier
      when '>'
        (other.width < width || other.height < height) ? scaled_to_fit(other) : self
      when '<'
        (other.width > width && other.height > height) ? scaled_to_fit(other) : self
      when '%'
        scaled_by(other)
      when '@'
        scaled_by((other.width * 100).fdiv(width * height))
      else
        scaled_to_fit(other)
      end
    end
    alias * transformed_by

    def ==(other)
      to_s == other.to_s
    end

    def =~(other)
      height.to_i == other.height.to_i && width.to_i == other.width.to_i
    end

    def scaled_to_fit(other)
      if other.width > 0 && other.height == 0
        Geometry.new(other.width, height * other.width / width)
      elsif other.width == 0 && other.height > 0
        Geometry.new(width * other.height / height, other.height)
      else
        product_width = other.width * height
        product_height = other.height * width
        if product_width == product_height
          other.without_modifier
        elsif product_width > product_height
          scaled_width = (width * other.height.fdiv(height)).round
          Geometry.new(scaled_width, other.height)
        else
          scaled_height = (height * other.width.fdiv(width)).round
          Geometry.new(other.width, scaled_height)
        end
      end
    end

    def scaled_by(other)
      if other.is_a?(Numeric)
        scaled_width = (width * other.fdiv(100)).round
        scaled_height = (height * other.fdiv(100)).round
        return Geometry.new(scaled_width, scaled_height)
      end

      other = Geometry.new("#{other}%") unless other.is_a?(Geometry)
      if other.height > 0
        Geometry.new(width * other.width / 100, height * other.height / 100)
      else
        Geometry.new(width * other.width / 100, height * other.width / 100)
      end
    end

    def aspect
      return nil if width.to_f == 0.0 || height.to_f == 0.0

      width.to_f / height.to_f
    end

    def square?
      width.to_i == height.to_i
    end

    def vertical?
      height.to_i > width.to_i
    end

    def horizontal?
      width.to_i > height.to_i
    end

    def to_s
      suffix = modifier.to_s
      "#{width}x#{height}#{suffix}"
    end
  end
end
