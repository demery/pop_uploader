# PopUploader

- Read image names metadata from a spreadsheet
- Upload image and metadata to flickr

# Flickr License IDs

    <licenses>
      <license id="0" name="All Rights Reserved" url="" />
      <license id="1" name="Attribution-NonCommercial-ShareAlike License"
        url="http://creativecommons.org/licenses/by-nc-sa/2.0/" />
      <license id="2" name="Attribution-NonCommercial License"
        url="http://creativecommons.org/licenses/by-nc/2.0/" />
      <license id="3" name="Attribution-NonCommercial-NoDerivs License"
        url="http://creativecommons.org/licenses/by-nc-nd/2.0/" />
      <license id="4" name="Attribution License"
        url="http://creativecommons.org/licenses/by/2.0/" />
      <license id="5" name="Attribution-ShareAlike License"
        url="http://creativecommons.org/licenses/by-sa/2.0/" />
      <license id="6" name="Attribution-NoDerivs License"
        url="http://creativecommons.org/licenses/by-nd/2.0/" />
      <license id="7" name="No known copyright restrictions"
        url="http://flickr.com/commons/usage/" />
      <license id="8" name="United States Government Work"
        url="http://www.usa.gov/copyright.shtml" />
    </licenses>

# Image description template

    <b>Repository</b>: University of Pennsylvania, Kislak Center for Special Collections, Rare Books and Manuscripts
    <b>Collection</b>: Furness
    <a href="http://franklin.library.upenn.edu/record.html?id=FRANKLIN_1540420" rel="nofollow">EC Sh155 622oc</a>
    <b>Copy title</b>: The tragoedy of Othello, the Moore of Venice : as it hath beene divers times acted at the Globe, and at the Black-Friers, by His Majesties servants / written by William Shakespeare.
    <b>Author(s)</b>: Shakespeare, William
    <b>Published</b>: England, London, 1665
    <b>Printer/Publisher:</b> Printed for William Leak

    <b>Provenance Evidence:</b> Inscription, Sale Record
    <b>Location on Book:</b>  Front Free Endpaper
    <b>Identified:</b>  Furness, Horace Howard (1833-1912), Buyer
    <b>Identified Date:</b> 1877
    <b>Identified Place:</b> Philadelphia

    <b>Transcription:</b> Horace Howard Furness, Bought at John Kershaws Sale 13 July 1877
    <b>Associated Names:</b> Horace Howard Furness | John Kershaw
    <b>Associated Date:</b> 1877

# TODO

Update flickr photo description template

Add 'citation' to list of columns

pop-upload.rb:
        - upload

Create Pop::Connection object

       - #set_comment flickr_id

Pop::Metadata - add transcriptions

Flickr Description
  - Add call number tag URL for "All images from this book"
  - Add transcription

Re-write spreadsheet with Flickr ID

Gemify the whole business.

- Test creation of image and set management

? Test uploading from URL instead of local file.
     Why? What's the need for this? Easier with Box?

Done: Build deletion script for development

Done - Done: Get development API key
Done
Done - Done: Test upload of image to Flickr
Done
Done     - Done: Title
Done     - Done: Description
Done     - Done: Tags
Done     - Done: Mark public
Done     - Done: License
Done
Done - Done: Read data from spreadsheet
Done

Welcome to your new gem! In this directory, you'll find the files you
need to be able to package up your Ruby library into a gem. Put your
Ruby code in the file `lib/pop_uploader`. To experiment with that
code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pop_uploader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pop_uploader

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pop_uploader/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
