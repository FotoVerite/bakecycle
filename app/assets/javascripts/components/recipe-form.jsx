var React = require('react');
var RecipeItemsForm = require('./recipe-items-form');
var RecipeItemStore = require('../stores/recipe-item-store');
var RecipeStore = require('backbone').Model;
var TextInput = require('./bakecycle-text-input');


module.exports = React.createClass({
  getInitialState: function() {
    var items = new RecipeItemStore(this.props.recipeItems);
    this.addBlankForm(items);
    items.onChange(() => { this.setState({items}); });

    var recipe = new RecipeStore(this.props);
    recipe.on('change', () => { this.setState({recipe}); });
    return { items, recipe };
  },

  addBlankForm: function(items) {
    if (!items.length()) {
      return items.add();
    }
    if (items.getLast().id) {
      items.add();
    }
  },

  willReceiveProps: function(nextProps) {
    this.state.items.updateAll(nextProps.recipeItems);
    this.addBlankForm(this.state.items);
    this.state.recipe.set(nextProps);
  },

  updateField: function(event) {
    var updatedField = {};
    updatedField[event.target.dataset.field] = event.target.value;
    this.state.recipe.set(updatedField);
  },

  errorFor: function(field) {
    if (!this.props.errors[field]) { return; }
    return (<small className="error">{this.props.errors[field]}</small>);
  },

  errorClassFor: function(field) {
    if (!this.props.errors[field]) { return; }
    return 'error';
  },

  showLeadDays: function() {
    var recipe = this.state.recipe;
    var { recipeType } = recipe.toJSON();
    if (recipeType !== 'dough') { return; }
    return (
      <div className="row">
        <div className="small-4 columns end">
        <TextInput
          model={recipe}
          field='leadDays'
          name='recipe[lead_days]'
          label='Lead Days'
          required
          error={this.props.errors.lead_days} />
        </div>
      </div>
    );
  },

  mixUnitsOptions: function() {
    var { mixUnits } = this.state.recipe.toJSON();
    return mixUnits.map((mixUnit) => {
      return <option key={mixUnit[0]} value={mixUnit[0]}>{mixUnit[0]}</option>;
    });
  },

  recipeTypeOptions: function() {
    var { recipeTypes } = this.state.recipe.toJSON();
    return recipeTypes.map((recipeType) => {
      return <option key={recipeType[0]} value={recipeType[0]}>{recipeType[0]}</option>;
    });
  },

  render: function() {
    var recipe = this.state.recipe;
    var {
      mixSize,
      mixSizeUnit,
      note,
      recipeType
    } = recipe.toJSON();

    return (<div>
      <fieldset>
        <legend>Recipe Information</legend>
        <div className="row">
          <div className="small-12 columns">
            <TextInput
              model={recipe}
              field='name'
              name='recipe[name]'
              label='Name'
              required
              error={this.props.errors.name} />
          </div>
        </div>
        <div className="row">
          <div className="small-12 columns">
            <div className={`input text optional recipe_note ${this.errorClassFor('Note')}`}>
              <label className="text optional" htmlFor="recipe_note">Note</label>
              <textarea
                id="recipe_note"
                data-field="note"
                className="text optional"
                name="recipe[note]"
                onChange={this.updateField}
                value={note} >
              </textarea>
              {this.errorFor('note')}
            </div>
          </div>
        </div>
        <div className="row">
          <div className="small-4 columns">
            <div className={`input select required recipe_recipe_type ${this.errorClassFor('recipe_type')}`}>
              <label className="select required" htmlFor="recipe_recipe_type">
                Recipe type <abbr title="required">*</abbr>
              </label>
              <select
                id="recipe_recipe_type"
                data-field="recipeType"
                value={recipeType}
                onChange={this.updateField}
                className="select required"
                name="recipe[recipe_type]" >
                {this.recipeTypeOptions()}
              </select>
              {this.errorFor('recipe_type')}
            </div>
          </div>
          <div className="small-4 columns">
            <div className={`input text optional recipe_mix_size ${this.errorClassFor('mix_size')}`}>
              <label htmlFor="recipe_mix_size">Mix Size</label>
              <input
                id="recipe_mix_size"
                data-field="mixSize"
                className="input optional"
                name='recipe[mix_size]'
                onChange={this.updateField}
                type="text"
                value={mixSize} />
              {this.errorFor('mix_size')}
            </div>
            <p className="help-text">
              * Pre-ferment mix bowls will match motherdough bowls when only included in one motherdough
            </p>
          </div>
          <div className="small-4 columns">
            <div className={`input select required recipe_mix_size_unit ${this.errorClassFor('mix_size_unit')}`}>
              <label className="select" htmlFor="recipe_mix_size_unit">Mix Units</label>
              <select
                id="recipe_mix_size_unit"
                data-field="mixSizeUnit"
                value={mixSizeUnit}
                onChange={this.updateField}
                className="select required"
                name="recipe[mix_size_unit]"
              >
                {this.mixUnitsOptions()}
              </select>
              {this.errorFor('mix_size_unit')}
            </div>
          </div>
        </div>
        {this.showLeadDays()}
      </fieldset>
      <RecipeItemsForm recipe={this.state.recipe} recipeItems={this.state.items} />
    </div>);
  }
});
