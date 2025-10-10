return {
    "mfussenegger/nvim-jdtls",
    dependencies = { "folke/which-key.nvim" },
    ft = { "java" },
    opts = function()
        local cmd = { vim.fn.exepath("jdtls") }

        -- Check for mason.nvim and lombok
        local has_mason, mason_registry = pcall(require, "mason-registry")
        if has_mason then
            local lombok_jar = vim.fn.expand("$MASON/share/jdtls/lombok.jar")
            if vim.fn.filereadable(lombok_jar) == 1 then
                table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
            end
        end

        return {
            root_dir = function(path)
                return vim.fs.root(path,
                    { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", ".classpath", ".project" })
            end,

            project_name = function(root_dir)
                return root_dir and vim.fs.basename(root_dir)
            end,

            jdtls_config_dir = function(project_name)
                return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
            end,
            jdtls_workspace_dir = function(project_name)
                return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
            end,

            cmd = cmd,

            full_cmd = function(opts)
                local fname = vim.api.nvim_buf_get_name(0)
                local root_dir = opts.root_dir(fname)
                local project_name = opts.project_name(root_dir)
                local cmd = vim.deepcopy(opts.cmd)
                if project_name then
                    vim.list_extend(cmd, {
                        "-configuration",
                        opts.jdtls_config_dir(project_name),
                        "-data",
                        opts.jdtls_workspace_dir(project_name),
                    })
                end
                return cmd
            end,

            dap = { hotcodereplace = "auto", config_overrides = {} },
            dap_main = {},
            test = true,

            settings = {
                java = {
                    inlayHints = {
                        parameterNames = {
                            enabled = "all",
                        },
                    },
                },
            },
        }
    end,

    config = function(_, opts)
        local has_mason, mason_registry = pcall(require, "mason-registry")
        local has_dap = pcall(require, "dap")

        -- Gather debug/test bundles if available
        local bundles = {}
        if has_mason and has_dap then
            if mason_registry.is_installed("java-debug-adapter") then
                vim.list_extend(
                    bundles,
                    vim.fn.glob("$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin-*.jar", false, true)
                )

                if opts.test and mason_registry.is_installed("java-test") then
                    vim.list_extend(bundles, vim.fn.glob("$MASON/share/java-test/*.jar", false, true))
                end
            end
        end

        local function extend_or_override(base, extra)
            if type(extra) ~= "table" then
                return base
            end
            return vim.tbl_deep_extend("force", base, extra)
        end

        local function attach_jdtls()
            local fname = vim.api.nvim_buf_get_name(0)
            local config = extend_or_override({
                cmd = opts.full_cmd(opts),
                root_dir = opts.root_dir(fname),
                init_options = { bundles = bundles },
                settings = opts.settings,
            }, opts.jdtls)

            -- Add cmp capabilities if available
            local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            if has_cmp then
                config.capabilities = cmp_nvim_lsp.default_capabilities()
            end

            require("jdtls").start_or_attach(config)
        end

        -- Automatically attach JDTLS for Java buffers
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "java" },
            callback = attach_jdtls,
        })

        -- Setup which-key and DAP once LSP attaches
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if not client or client.name ~= "jdtls" then
                    return
                end

                local wk_ok, wk = pcall(require, "which-key")
                if wk_ok then
                    wk.add({
                        {
                            mode = "n",
                            buffer = args.buf,
                            { "<leader>cx",  group = "extract" },
                            { "<leader>cxv", require("jdtls").extract_variable_all, desc = "Extract Variable" },
                            { "<leader>cxc", require("jdtls").extract_constant,     desc = "Extract Constant" },
                            { "<leader>cgs", require("jdtls").super_implementation, desc = "Goto Super" },
                            { "<leader>cgS", require("jdtls.tests").goto_subjects,  desc = "Goto Subjects" },
                            { "<leader>co",  require("jdtls").organize_imports,     desc = "Organize Imports" },
                        },
                    })
                    wk.add({
                        {
                            mode = "v",
                            buffer = args.buf,
                            { "<leader>cx",  group = "extract" },
                            { "<leader>cxm", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],       desc = "Extract Method" },
                            { "<leader>cxv", [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]], desc = "Extract Variable" },
                            { "<leader>cxc", [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],     desc = "Extract Constant" },
                        },
                    })
                end

                -- Setup debugging if available
                if has_dap and has_mason and mason_registry.is_installed("java-debug-adapter") then
                    require("jdtls").setup_dap(opts.dap)
                    if opts.dap_main then
                        require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)
                    end

                    if opts.test and mason_registry.is_installed("java-test") then
                        wk.add({
                            {
                                mode = "n",
                                buffer = args.buf,
                                { "<leader>t",  group = "test" },
                                {
                                    "<leader>tt",
                                    function()
                                        require("jdtls.dap").test_class({
                                            config_overrides = type(opts.test) ~= "boolean" and
                                                opts.test.config_overrides or nil,
                                        })
                                    end,
                                    desc = "Run All Tests",
                                },
                                {
                                    "<leader>tr",
                                    function()
                                        require("jdtls.dap").test_nearest_method({
                                            config_overrides = type(opts.test) ~= "boolean" and
                                                opts.test.config_overrides or nil,
                                        })
                                    end,
                                    desc = "Run Nearest Test",
                                },
                                { "<leader>tT", require("jdtls.dap").pick_test, desc = "Pick Test" },
                            },
                        })
                    end
                end

                if opts.on_attach then
                    opts.on_attach(args)
                end
            end,
        })

        -- Call attach once on load
        attach_jdtls()
    end,
}
