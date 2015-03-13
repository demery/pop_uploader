module PopUploader
  module GlobalHelpers
    def self.included base
      base.let (:tmpdir) { ENV['TMPDIR'] || '/tmp' }
    end
  end
end
