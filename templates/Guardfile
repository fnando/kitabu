notification :off
interactor :off

guard :shell do
  watch %r[^(?!output)] do |m|
    `kitabu export`
  end
end
