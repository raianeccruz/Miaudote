<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
// use Illuminate\Database\Eloquent\Factories\HasFactory;

class Favorito extends Model
{
    protected $fillable = [
        'user_id',
        'animal_id',
    ];

    protected $table = 'favoritos';

    public function usuario()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function animal()
    {
        return $this->belongsTo(Animal::class);
    }
}
