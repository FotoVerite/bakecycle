var React = require('react');
var RecipeItemFields = require('./recipe-item-fields');

module.exports = React.createClass({
  componentWillMount: function() {
    this.placeholder = document.createElement('div');
    this.placeholder.className = 'draggable-placeholder';
  },

  addItem: function(event) {
    event.preventDefault();
    this.props.recipeItems.add({});
  },

  availableInclusions: function() {
    if (this.props.recipe.get('recipeType') === 'dough') {
      return this.props.recipe.get('availableInclusions');
    } else {
      return this.props.recipe.get('availableRecipeIngredients');
    }
  },

  dragStart: function(e) {
    this.dragged = e.target;
    this.draggedOver = false;
    e.dataTransfer.effectAllowed = 'move';
    // Firefox requires calling dataTransfer.setData
    e.dataTransfer.setData('text/html', this.dragged);
  },

  dragEnd: function() {
    this.dragged.style.display = 'block';
    this.placeholder.remove();
    if (!this.draggedOver) {
      return;
    }
    var draggedId = this.dragged.dataset.id;
    var targetId = this.draggedOver.dataset.id;
    this.props.recipeItems.move(draggedId, targetId, this.draggedPosition === 'after');
  },

  dragOver: function(e) {
    e.preventDefault();
    var over = $(e.target).closest('[draggable=true]').get(0);
    if (!over) {
      return;
    }
    this.draggedOver = over;
    this.dragged.style.display = 'none';

    // for better dragging ux
    var overBoundingBox = this.draggedOver.getBoundingClientRect();
    var middle = overBoundingBox.height / 2;
    var relativeToMiddle = e.clientY - overBoundingBox.top - middle;
    var parent = this.draggedOver.parentNode;
    if (relativeToMiddle > 0) {
      this.draggedPosition = 'after';
      parent.insertBefore(this.placeholder, this.draggedOver.nextElementSibling);
    } else {
      this.draggedPosition = 'before';
      parent.insertBefore(this.placeholder, this.draggedOver);
    }
  },

  render: function() {
    var fields = this.props.recipeItems.map((model) => {
      return (<RecipeItemFields
        key={model.cid}
        availableInclusions={this.availableInclusions()}
        model={model}
        dragStart={this.dragStart}
        dragEnd={this.dragEnd} />);
    });

    return (<div onDragOver={this.dragOver} >
      <fieldset>
        <legend>Ingredients</legend>
        <div className="row collapse">
          <div className="small-12 medium-4 columns">
            <label className="show-for-medium-up">Ingredient</label>
          </div>
          <div className="small-12 medium-2 columns">
            <label className="show-for-medium-up">Baker's %</label>
          </div>
          <div className="small-12 medium-2 columns">
            <label className="show-for-medium-up">Type</label>
          </div>
          <div className="small-12 medium-2 columns end">
            <label className="show-for-medium-up">Lead time</label>
          </div>
        </div>
        {fields}
        <a href='#' onClick={this.addItem} className="button" >Add New Ingredient</a>
      </fieldset>
    </div>);
  }
});
