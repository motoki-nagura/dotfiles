-- Telescope keymap quick reference:
--   <leader>ff  Find files below the current working directory.
--   <leader>fg  Search text across files with ripgrep.
--   <leader>fb  Search open buffers; press Ctrl-D to close the selected buffer.
--   <leader>fh  Search Neovim and plugin help tags.
--   <leader>fd  Choose a directory by path, then find files below it.
--   <leader>fm  Browse directories and search files across multiple directories.
--
-- Multi-directory browser controls:
--   Enter       Open the highlighted directory.
--   Ctrl-A      Add the current directory to the search targets.
--   Ctrl-F      Search files across all added directories.
--   Ctrl-L      Show the currently added directories.
--   Ctrl-R      Clear all added directories.

local function multi_directory_files()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local sorters = require("telescope.sorters")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")
  local make_entry = require("telescope.make_entry")

  local selected_dirs = {}
  local selected_set = {}
  local current_dir = vim.fn.getcwd()

  local function normalize(path)
    return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
  end

  local function directory_entries(path)
    local entries = {}
    local parent = vim.fs.dirname(path)

    if parent and parent ~= path then
      table.insert(entries, {
        value = parent,
        display = "../",
        ordinal = "..",
      })
    end

    local ok, iterator = pcall(vim.fs.dir, path)
    if not ok or not iterator then
      return entries
    end

    local directories = {}
    for name, kind in iterator do
      if kind == "directory" then
        table.insert(directories, name)
      end
    end

    table.sort(directories)
    for _, name in ipairs(directories) do
      local full_path = vim.fs.joinpath(path, name)
      table.insert(entries, {
        value = full_path,
        display = name .. "/",
        ordinal = name,
      })
    end

    return entries
  end

  local function directory_finder()
    return finders.new_table({
      results = directory_entries(current_dir),
      entry_maker = function(entry)
        return entry
      end,
    })
  end

  local function show_selected()
    if #selected_dirs == 0 then
      vim.notify("No directories selected", vim.log.levels.INFO)
      return
    end

    vim.notify(
      "Selected directories:\n" .. table.concat(selected_dirs, "\n"),
      vim.log.levels.INFO
    )
  end

  local function add_current_directory()
    local dir = normalize(current_dir)
    if selected_set[dir] then
      vim.notify("Already selected: " .. dir, vim.log.levels.INFO)
      return
    end

    selected_set[dir] = true
    table.insert(selected_dirs, dir)
    vim.notify("Added: " .. dir, vim.log.levels.INFO)
  end

  pickers
    .new({}, {
      prompt_title = "Browse directories",
      finder = directory_finder(),
      sorter = sorters.get_fuzzy_file(),
      attach_mappings = function(prompt_bufnr, map)
        local function open_directory()
          local selection = action_state.get_selected_entry()
          if not selection then
            return
          end

          current_dir = normalize(selection.value)
          local picker = action_state.get_current_picker(prompt_bufnr)
          picker.prompt_title = "Browse directories: " .. current_dir
          picker:refresh(directory_finder(), { reset_prompt = true })
        end

        local function search()
          actions.close(prompt_bufnr)

          if #selected_dirs == 0 then
            vim.notify("Add at least one directory first", vim.log.levels.WARN)
            return
          end

          local command = {
            "rg",
            "--files",
            "--hidden",
            "--glob",
            "!.git",
            "--",
          }
          vim.list_extend(command, selected_dirs)

          pickers
            .new({}, {
              prompt_title = "Files in selected directories",
              finder = finders.new_oneshot_job(command, {
                entry_maker = make_entry.gen_from_file({}),
              }),
              previewer = previewers.vim_buffer_cat.new({}),
              sorter = sorters.get_fuzzy_file(),
            })
            :find()
        end

        local function clear_selected()
          selected_dirs = {}
          selected_set = {}
          vim.notify("Selected directories cleared", vim.log.levels.INFO)
        end

        actions.select_default:replace(open_directory)
        map("i", "<C-a>", add_current_directory)
        map("n", "<C-a>", add_current_directory)
        map("i", "<C-f>", search)
        map("n", "<C-f>", search)
        map("i", "<C-l>", show_selected)
        map("n", "<C-l>", show_selected)
        map("i", "<C-r>", clear_selected)
        map("n", "<C-r>", clear_selected)

        return true
      end,
    })
    :find()
end

return {
  "nvim-telescope/telescope.nvim",
  -- Track the current upstream version. The old 0.1.x branch uses a removed
  -- Treesitter API on recent Neovim versions.
  version = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Telescope",
  keys = {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "Find files",
    },
    {
      "<leader>fg",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Live grep",
    },
    {
      "<leader>fb",
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "Find buffers",
    },
    {
      "<leader>fh",
      function()
        require("telescope.builtin").help_tags()
      end,
      desc = "Help tags",
    },
    {
      "<leader>fd",
      function()
        local directory = vim.fn.input(
          "Search directory: ",
          vim.fn.getcwd() .. "/",
          "dir"
        )

        if directory ~= "" then
          require("telescope.builtin").find_files({
            cwd = vim.fn.expand(directory),
          })
        end
      end,
      desc = "Find files in directory",
    },
    {
      "<leader>fm",
      multi_directory_files,
      desc = "Find files in multiple directories",
    },
  },
  config = function()
    local actions = require("telescope.actions")

    require("telescope").setup({
      pickers = {
        buffers = {
          -- Keep the filename visible even when the full path is long.
          path_display = {
            "filename_first",
            "truncate",
          },
          mappings = {
            i = {
              ["<C-d>"] = actions.delete_buffer,
            },
            n = {
              ["<C-d>"] = actions.delete_buffer,
              ["dd"] = actions.delete_buffer,
            },
          },
        },
      },
    })
  end,
}
