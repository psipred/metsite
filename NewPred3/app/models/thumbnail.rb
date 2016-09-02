class Thumbnail < ActiveRecord::Base
  belongs_to :request_result

  def self.make_image_thumbnail(result, newx, newy)
    require 'RMagick'

    ret = Thumbnail.new
    source = Magick::Image.from_blob(result.data).first

    source.change_geometry!("#{newx}x#{newy}") { |cols, rows, img|
      img.resize!(cols, rows)
      ret.request_result_id = result.id
      ret.x = img.columns
      ret.y = img.rows
      ret.data = img.to_blob
      ret.save!
      #img.destroy!
    }

    return ret
  end
end
