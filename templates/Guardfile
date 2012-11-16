notification :off
interactor :off

guard :shell do
  watch %r[^(?!output|templates/scss)] do |m|
    `kitabu export`
  end

  watch %r[^templates/scss] do |m|
    `sass --unix-newlines templates/scss:templates`
  end
end
