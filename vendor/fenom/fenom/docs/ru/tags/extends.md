Тег `{extends}`
=============

Тег `{extends}` реализует [наследование](../inheritance.md) шаблонов, иерархия, обратная {include}. То есть шаблон сам выбирает своего родителя.

### `{extends}`

Родительский шаблон можно задать единожды и до объявления какого-либо блока.

```smarty
{extends 'parent.tpl'}
```

**Замечание:**
Имя родительского шаблона может быть задан динамически, но в этом случае производительность шаблона значительно снижается.
```smarty
{extends $parent_tpl}
```

### `{block}`

Блок указывает фрагмент шаблона, который будет передан родителю. Имя блока должно быть задано явно:

```smarty
{block bk1}content 1{/block}
...
{block 'bk2'}content 2{/block}
```


### `{use}`

Что бы импортировать блоки из другого шаблона используйте тег {use}:

```smarty
{use 'blocks.tpl'}
```

### `{parent}`

```smarty
{block 'block1'}
  content ...
  {parent}
  content ...
{/block}
```

### `{paste}`

Иставка кода блока в любое место через тег `{paste}`

```smarty
{block 'b1'}
  ...
{/block}

{paste 'b1'}
```

### `{$.block}`

Проверка наличия блока через глобальную переменную `$.block`

```smarty
{if $.block.header}
    ...
{/if}
```
