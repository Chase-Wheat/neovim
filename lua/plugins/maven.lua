return {
    "eatgrass/maven.nvim",
    cmd = { "Maven", "MavenExec" },
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
        require('maven').setup({
            executable = "./mvnw",
            commands = {
                { cmd = { "compile", "exec:java" }, desc = "execute main class" }
            }
        })
    end
}
