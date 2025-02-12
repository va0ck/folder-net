import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Folder-Net",
  description: "Roblox Remotes & Bindables for IDEs.",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Documentation', link: '/docs' }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/va0ck/folder-net' }
    ]
  }
})
