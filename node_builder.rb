require "fileutils"

class ProjectBuilder

  attr_accessor :project_name
  attr_accessor :project_path
  attr_accessor :js_path
  attr_accessor :scss_path
  attr_accessor :img_path

  def initialize(project)
    self.project_name = project
    self.project_path = File.expand_path(File.join("~", "Desktop", project_name))
    self.js_path = File.join(project_path, "js")
    self.scss_path = File.join(project_path, "scss")
    self.img_path = File.join(project_path, "img")
  end

  def build_folders
    [
      img_path,
      js_path,
      scss_path,
      img_path,
    ].each do |folder|
      FileUtils.mkdir_p(folder)
    end
  end

  def write_contents(path, filename, contents = "")
    File.open(File.join(path, filename), "w") do |f|
      f.write(contents)
    end
  end

  def build_files
    write_contents project_path, ".gitignore", <<-TEXT
node_modules/
bower_components/
build/
tmp/
.DS_Store
.env
TEXT

  write_contents project_path, "README.md", <<-TEXT
# <!--PROJECT NAME HERE-->

This project will save the world!

### Prerequisites

Web browser with ES6 compatibility
Examples: Chrome, Safari

* npm
* bower
* ruby

### Installing

These instructions have been verified to work on MacOS.

There are a few terminal commands you will need to run to get the app to launch locally on your machine. First though, you will need to clone this repository to your machine and navigate to its folder in your terminal.

Once you have navigated to the correct directory, you will run the following commands:

* bower install
* npm install
* gulp serve

The required packages may take a few minutes to download and install due to the speed of your machine and your Internet connection. The last command should launch the app in your browser! That's it!

## Built With

* HTML
* CSS/SASS
* Bootstrap https://getbootstrap.com/
* ES6
* Jquery https://jquery.com/
* Node
* Bower

## Authors

* <!--YOUR NAME HERE-->

## License

MIT License

Copyright (c) <!--YOUR NAME & YEAR HERE-->

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
TEXT

  write_contents project_path, "index.html", <<-TEXT
<!DOCTYPE html>
<html>
  <head>
    <script src="bower_components/jquery/dist/jquery.min.js"></script>
    <link rel="stylesheet" href="bower_components/bootstrap/dist/css/bootstrap.min.css">
    <script src="bower_components/bootstrap/dist/js/bootstrap.min.js"></script>
    <script src="bower_components/moment/min/moment.min.js"></script>
    <script type="text/javascript" src="build/js/app.js"></script>
    <link rel="stylesheet" href="build/css/styles.css">
    <title></title>
  </head>

  <body>
    <div class="container">

    </div>
  </body>

</html>

TEXT

  write_contents project_path, "bower.json", <<-TEXT
{
  "name": "#{project_name}",
  "description": "",
  "main": "index.js",
  "license": "ISC",
  "moduleType": [],
  "homepage": "",
  "ignore": [
    "**/.*",
    "node_modules",
    "bower_components",
    "test",
    "tests"
  ],
  "dependencies": {
    "jquery": "^3.2.1",
    "bootstrap": "^3.3.7",
    "moment": "^2.18.1"
  }
}

TEXT

  write_contents project_path, "package.json", <<-TEXT
{
  "name": "#{project_name}",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \\"Error: no test specified\\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "babel-preset-es2015": "^6.24.1",
    "bower-files": "^3.14.1",
    "browser-sync": "^2.18.12",
    "browserify": "^14.3.0",
    "del": "^2.2.2",
    "gulp": "^3.9.1",
    "gulp-babel": "^6.1.2",
    "gulp-concat": "^2.6.1",
    "gulp-jshint": "^2.0.4",
    "gulp-sass": "^3.1.0",
    "gulp-sourcemaps": "^2.6.0",
    "gulp-uglify": "^3.0.0",
    "gulp-util": "^3.0.8",
    "jshint": "^2.9.4",
    "vinyl-source-stream": "^1.1.0"
  }
}
TEXT

  write_contents project_path, "Gulpfile.js", <<-TEXT
var browserSync = require('browser-sync').create();
var lib = require('bower-files')();
var gulp = require('gulp');
var browserify = require('browserify');
var source = require('vinyl-source-stream');
var uglify = require('gulp-uglify');
var utilities = require('gulp-util');
var del = require('del');
var jshint = require('gulp-jshint');
var concat = require('gulp-concat');
var sass = require('gulp-sass');
var sourcemaps = require('gulp-sourcemaps');
var babel = require("gulp-babel");

var buildProduction = utilities.env.production;

var lib = require('bower-files')({
  "override":{
    "bootstrapp": {
      "main": [
        "less/bootstrap.less",
        "dist/css/bootstrap.css",
        "dist/js/bootstrap.js"
      ]
    }
  }
});


gulp.task('jshint', function(){
  return gulp.src(['js/*.js'])
    .pipe(jshint())
    .pipe(jshint.reporter('default'));
});

gulp.task('concatInterface', function() {
  return gulp.src(['js/*-interface.js'])
    .pipe(concat('allConcat.js'))
    .pipe(gulp.dest('./tmp'));
});

gulp.task('jsBrowserify', ['concatInterface'], function() {
  return browserify({ entries: ['./tmp/allConcat.js'] })
    .bundle()
    .pipe(source('app.js'))
    .pipe(gulp.dest('./build/js'));
});

gulp.task('minifyScripts', ['jsBrowserify'], function(){
  return gulp.src('./build/js/app.js')
    .pipe(babel({ presets: ['es2015'] }))
    .pipe(uglify())
    .pipe(gulp.dest('./build/js'));
});

gulp.task('jsBower', function() {
  return gulp.src(lib.ext('js').files)
    .pipe(concat('vendor.min.js'))
    .pipe(uglify())
    .pipe(gulp.dest('./build/js'));
});

gulp.task('cssBower', function() {
  return gulp.src(lib.ext('css').files)
    .pipe(concat('vendor.css'))
    .pipe(gulp.dest('./build/css'));
});

gulp.task('bower', ['jsBower', 'cssBower']);

gulp.task('clean', function(){
  return del(['build', 'tmp']);
});

gulp.task('build', ['clean'], function(){
  if (buildProduction) {
    gulp.start('minifyScripts');
  } else {
    gulp.start('jsBrowserify');
  }
  gulp.start('bower');
  gulp.start('cssBuild');
});

gulp.task('serve', ['build'], function() {
  browserSync.init({
    server: {
      baseDir: './',
      index: 'index.html'
    }
  });
  gulp.watch(['js/*.js'], ['jsBuild']);
  gulp.watch(['bower.json'], ['bowerBuild']);
  gulp.watch(['*.html'], ['htmlBuild']);
  gulp.watch(['scss/*.scss'], ['cssBuild']);
});

gulp.task('jsBuild', ['jsBrowserify', 'jshint'], function(){
  browserSync.reload();
});

gulp.task('bowerBuild', ['bower'], function(){
  browserSync.reload();
});

gulp.task('htmlBuild', function(){
  browserSync.reload();
});

gulp.task('cssBuild', function() {
  return gulp.src('scss/*.scss')
    .pipe(sourcemaps.init())
    .pipe(sass())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('./build/css'))
    .pipe(browserSync.stream());
});
TEXT

  write_contents scss_path, "styles.scss"

  write_contents js_path, "#{project_name}.js"

  write_contents js_path, "#{project_name}-interface.js", <<-TEXT
$(document).ready(function(){

});
TEXT

  end
end

puts "What is the name of your project?"

project_name = $stdin.gets.chomp
project_name.gsub!(/\s/, "_")
project_name.gsub!(/\W/, "")
project_name = "project" if project_name == ""

puts "Building #{project_name}........"

new_project = ProjectBuilder.new(project_name)

new_project.build_folders
new_project.build_files

puts "Running bower........"

`(cd #{new_project.project_path}; bower install)`

puts "Running npm (this might take a minute)........"

`(cd #{new_project.project_path}; npm install)`

puts "#{new_project.project_name} built at:"
puts new_project.project_path
puts "Don't forget to git init!"
