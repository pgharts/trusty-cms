module Paperclip

  class TransformationError < PaperclipError; end
  class StyleError < PaperclipError; end
  
  class Geometry
    
    # Returns a new Geometry object with the the same dimensions as this but with no modifier.
    def without_modifier
      Geometry.new(self.width, self.height)
    end
    
    # Returns the dimensions that would result if a thumbnail was created by transforming this geometry into that geometry.
    # Its purpose is to mimic imagemagick conversions. Used like so:
    #    file_geometry.transformed_by(style_geometry)
    # it returns the size of the thumbnail image you would get by applying that rule.
    # This saves us having to go back to the file, which is expensive with S3.
    # We understand all the Imagemagick geometry arguments described at http://www.imagemagick.org/script/command-line-processing.php#geometry
    # including both '^' and paperclip's own '#' modifier.
    #
    def transformed_by (other)
      other = Geometry.parse(other) unless other.is_a? Geometry
      # if the two geometries are similar, or the destination geometry is a fixed size, the resulting dimensions are fixed
      return other.without_modifier if self =~ other || ['#', '!', '^'].include?(other.modifier)
      # otherwise, we apply the transformation
      raise TransformationError, "geometry is not transformable without both width and height" if self.height == 0 or self.width == 0
      case other.modifier
      when '>'
        (other.width < self.width || other.height < self.height) ? scaled_to_fit(other) : self
      when '<'
        (other.width > self.width && other.height > self.height) ? scaled_to_fit(other) : self
      when '%'
        scaled_by(other)
      when '@'
        scaled_by(other.width * 100 / (self.width * self.height))
      else
        scaled_to_fit(other)
      end
    end
    alias :* :transformed_by
    
    # Tests whether two geometries are identical in dimensions and modifier. 
    def == (other)
      self.to_s == other.to_s
    end
    
    # Tests whether two geometries have the same dimensions, ignoring modifier.
    def =~ (other)
      self.height.to_i == other.height.to_i && self.width.to_i == other.width.to_i
    end
    
    # Scales this geometry to fit within that geometry.
    def scaled_to_fit(other)
      if (other.width > 0 && other.height == 0)
        Geometry.new(other.width, self.height * other.width / self.width)
      elsif (other.width == 0 && other.height > 0)
        Geometry.new(self.width * other.height / self.height, other.height)
      else
        ratio = Geometry.new( other.width / self.width, other.height / self.height )
        if ratio.square?
          other.without_modifier
        elsif ratio.horizontal?
          Geometry.new(ratio.height * self.width, other.height)
        else
          Geometry.new(other.width, ratio.width * self.height)
        end
      end
    end
    
    # Scales this geometry by the percentage(s) specified in that geometry.
    def scaled_by(other)
      other = Geometry.new("#{other}%") unless other.is_a? Geometry
      if other.height > 0
        Geometry.new(self.width * other.width / 100, self.height * other.height / 100)
      else
        Geometry.new(self.width * other.width / 100, self.height * other.width / 100)
      end
    end
  end
end