require 'rubygems'
require 'sitemap_generator'

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = Rails.application.secrets.global_url
SitemapGenerator::Sitemap.sitemaps_path = 'shared/'

SitemapGenerator::Sitemap.create do
  Page.active.find_each do |page|
    add p_path(slug: page.slug), lastmod: Time.current, changefreq: 'monthly', priority: 1
  end

  Category.find_each do |category|
    add category_path(category), lastmod: category.updated_at

    category.products.find_each do |product|
      add category_product_path(category, product), lastmod: product.updated_at
    end
  end
end

SitemapGenerator::Sitemap.ping_search_engines
