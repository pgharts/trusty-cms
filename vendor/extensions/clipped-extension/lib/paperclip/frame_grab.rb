module Paperclip
  class FrameGrab < Processor

    attr_accessor :time_offset, :current_geometry, :target_geometry, :whiny, :current_format, :target_format

    def initialize(file, options = {}, attachment = nil)
      super
      @file = file
      @time_offset = options[:time_offset] || '-4'
      geometry = options[:geometry]
      unless geometry.blank?
        @crop = geometry[-1,1] == '#'
        @target_geometry = Geometry.parse(geometry)
        @current_geometry = Geometry.parse(video_dimensions(file))
      end
      @current_format = File.extname(@file.path)
      @target_format = options[:format] || 'jpg'
      @basename = File.basename(@file.path, @current_format)
      @whiny = options[:whiny].nil? ? true : options[:whiny]
    end

    def crop?
      !!@crop
    end
    
    def make
      src = @file
      dst = Tempfile.new([ @basename, @target_format ].compact.join("."))
      dst.binmode

      begin
        # grab frame at offset
        cmd = %Q[-itsoffset #{time_offset} -i :source -y -vcodec mjpeg -vframes 1 -an -f rawvideo ]

        # if scale-and-crop parameters can be calculated, we pipe to convert for resizing
        if scale_and_crop = transformation_options
          cmd << %{pipe: | convert #{scale_and_crop} - #{target_format}:- }

        # otherwise we let ffmpeg resize the to the right size without preserving aspect ratio
        else
          cmd << %{-s #{target_geometry} pipe: }
        end

        # then pipe to composite to overlay video icon
        cmd << %{| composite -gravity center :icon - :dest }
        
        Paperclip.run('ffmpeg', cmd, :source => File.expand_path(src.path), :dest => File.expand_path(dst.path), :icon => AssetType.find(:video).icon_path, :swallow_stderr => false)
      rescue PaperclipCommandLineError => e
        raise PaperclipError, "There was an error processing the thumbnail for #{@basename}: #{e}" if whiny
      end
      
      dst
    end
    
    # get video dimensions in nasty hacky way
    def video_dimensions(file)
      dim = Paperclip.run('ffmpeg', '-i :source 2>&1', :source => File.expand_path(file.path), :expected_outcodes => [0,1], :swallow_stderr => false)
      $1 if dim =~ /(\d+x\d+)/
    end
    
    # Duplicated from Thumbnail. We can't just subclass because of assumed compatibility with Geometry.from_file
    def transformation_options
      if current_geometry
        scale, crop = current_geometry.transformation_to(target_geometry, crop?)
        trans = []
        trans << "-resize" << %["#{scale}"] unless scale.nil? || scale.empty?
        trans << "-crop" << %["#{crop}"] << "+repage" if crop
        trans.join(" ")
      end
    end
    
  end
end
