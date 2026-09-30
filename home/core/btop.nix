{ pkgs, ... }:
{
  programs.btop = {
    enable = true;
    package = pkgs.btop;
    themes.catppuccin_macchiato = ''
      # Main background, empty for terminal default, need to be empty if you want transparent background
      theme[main_bg]="#24273a"

      # Main text color
      theme[main_fg]="#cad3f5"

      # Title color for boxes
      theme[title]="#cad3f5"

      # Highlight color for keyboard shortcuts
      theme[hi_fg]="#8aadf4"

      # Background color of selected item in processes box
      theme[selected_bg]="#494d64"

      # Foreground color of selected item in processes box
      theme[selected_fg]="#8aadf4"

      # Color of inactive/disabled text
      theme[inactive_fg]="#8087a2"

      # Color of text appearing on top of graphs, i.e uptime and current network graph scaling
      theme[graph_text]="#f4dbd6"

      # Background color of the percentage meters
      theme[meter_bg]="#494d64"

      # Misc colors for processes box including mini cpu graphs, details memory graph and details status text
      theme[proc_misc]="#f4dbd6"

      # CPU, Memory, Network, Proc box outline colors
      theme[cpu_box]="#c6a0f6" #Mauve
      theme[mem_box]="#a6da95" #Green
      theme[net_box]="#ee99a0" #Maroon
      theme[proc_box]="#8aadf4" #Blue

      # Box divider line and small boxes line color
      theme[div_line]="#6e738d"

      # Temperature graph color (Green -> Yellow -> Red)
      theme[temp_start]="#a6da95"
      theme[temp_mid]="#eed49f"
      theme[temp_end]="#ed8796"

      # CPU graph colors (Teal -> Lavender)
      theme[cpu_start]="#8bd5ca"
      theme[cpu_mid]="#7dc4e4"
      theme[cpu_end]="#b7bdf8"

      # Mem/Disk free meter (Mauve -> Lavender -> Blue)
      theme[free_start]="#c6a0f6"
      theme[free_mid]="#b7bdf8"
      theme[free_end]="#8aadf4"

      # Mem/Disk cached meter (Sapphire -> Lavender)
      theme[cached_start]="#7dc4e4"
      theme[cached_mid]="#8aadf4"
      theme[cached_end]="#b7bdf8"

      # Mem/Disk available meter (Peach -> Red)
      theme[available_start]="#f5a97f"
      theme[available_mid]="#ee99a0"
      theme[available_end]="#ed8796"

      # Mem/Disk used meter (Green -> Sky)
      theme[used_start]="#a6da95"
      theme[used_mid]="#8bd5ca"
      theme[used_end]="#91d7e3"

      # Download graph colors (Peach -> Red)
      theme[download_start]="#f5a97f"
      theme[download_mid]="#ee99a0"
      theme[download_end]="#ed8796"

      # Upload graph colors (Green -> Sky)
      theme[upload_start]="#a6da95"
      theme[upload_mid]="#8bd5ca"
      theme[upload_end]="#91d7e3"

      # Process box color gradient for threads, mem and cpu usage (Sapphire -> Mauve)
      theme[process_start]="#7dc4e4"
      theme[process_mid]="#b7bdf8"
      theme[process_end]="#c6a0f6"
    '';
    settings = {
      # Keep this selection aligned with the native theme declared above.
      color_theme = "catppuccin_macchiato";
      theme_background = false;
      truecolor = true;
      force_tty = false;
      disable_presets = "Off";
      presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
      vim_keys = false;
      disable_mouse = false;
      rounded_corners = true;
      terminal_sync = true;
      graph_symbol = "braille";
      graph_symbol_cpu = "default";
      graph_symbol_gpu = "default";
      graph_symbol_mem = "default";
      graph_symbol_net = "default";
      graph_symbol_proc = "default";
      shown_boxes = "proc cpu";
      update_ms = 2000;
      proc_sorting = "memory";
      proc_reversed = false;
      proc_tree = true;
      proc_colors = true;
      proc_gradient = true;
      proc_per_core = true;
      proc_mem_bytes = true;
      proc_cpu_graphs = true;
      proc_info_smaps = false;
      proc_left = false;
      proc_filter_kernel = false;
      proc_follow_detailed = true;
      proc_aggregate = false;
      keep_dead_proc_usage = false;
      cpu_graph_upper = "Auto";
      cpu_graph_lower = "Auto";
      show_gpu_info = "Auto";
      cpu_invert_lower = true;
      cpu_single_graph = false;
      cpu_bottom = false;
      show_uptime = true;
      show_cpu_watts = true;
      check_temp = true;
      cpu_sensor = "Auto";
      show_coretemp = true;
      cpu_core_map = "";
      temp_scale = "celsius";
      base_10_sizes = false;
      show_cpu_freq = true;
      freq_mode = "first";
      clock_format = "%X";
      background_update = true;
      custom_cpu_name = "";
      disks_filter = "";
      mem_graphs = true;
      mem_below_net = false;
      zfs_arc_cached = true;
      show_swap = true;
      swap_disk = true;
      show_disks = true;
      only_physical = true;
      use_fstab = true;
      zfs_hide_datasets = false;
      disk_free_priv = false;
      show_io_stat = true;
      io_mode = false;
      io_graph_combined = false;
      io_graph_speeds = "";
      swap_upload_download = false;
      net_download = 100;
      net_upload = 100;
      net_auto = true;
      net_sync = true;
      net_iface = "";
      base_10_bitrate = "Auto";
      show_battery = true;
      selected_battery = "Auto";
      show_battery_watts = true;
      log_level = "WARNING";
      save_config_on_exit = true;
      nvml_measure_pcie_speeds = true;
      rsmi_measure_pcie_speeds = true;
      gpu_mirror_graph = true;
      shown_gpus = "nvidia amd intel apple";
      custom_gpu_name0 = "";
      custom_gpu_name1 = "";
      custom_gpu_name2 = "";
      custom_gpu_name3 = "";
      custom_gpu_name4 = "";
      custom_gpu_name5 = "";
    };
  };

}
