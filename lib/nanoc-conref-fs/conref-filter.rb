class ConrefFSFilter < Nanoc::Filter
  identifier :'conref-fs-filter'

  def run(content, _)
    NanocConrefFS::Conrefifier.liquify(@config, path: @item[:filename], content: content, rep: @rep.name)
  end
end
