local function init()
    require 'zestsystem.vim'.init()
    require 'zestsystem.theme'.init()
    require 'zestsystem.languages'.init()
    require 'zestsystem.noice'.init()
    require 'zestsystem.telescope'.init()
    require 'zestsystem.git-related'.init()
    require 'zestsystem.snippets'.init()
    require 'zestsystem.tools'.init()
end

return {
    init = init,
}
