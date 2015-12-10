class ConrefFSFilter < Nanoc::Filter
  identifier :'conref-fs-filter'

  def run(content, _)
    NanocConrefFS::Conrefifier.liquify(@item[:filename], content, @config.unwrap)
  end
end
