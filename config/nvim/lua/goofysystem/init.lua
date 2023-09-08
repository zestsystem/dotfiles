local function init()
    require 'goofysystem.vim'.init()
    require 'goofysystem.theme'.init()
    require 'goofysystem.languages'.init()
    require 'goofysystem.noice'.init()
    require 'goofysystem.telescope'.init()
    require 'goofysystem.git-related'.init()
    require 'goofysystem.snippets'.init()
end

return {
    init = init,
}
