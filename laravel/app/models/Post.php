<?php

class Post extends Eloquent {

	protected $table = 'posts';


  public function author()
  {
    return $this->belongsTo('Author');
  }

}
