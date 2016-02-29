let React = require('react');
let _ = require('underscore');

function filterClients(collection, filter) {
  function nameMatch(client) {
    let name = client.name.toLowerCase();
    let search = filter.name.toLowerCase();

    let searchChars = _.reject(search.split(''), char => char === ' ');
    let lastPostion = 0;
    return !_.detect(searchChars, char => {
      lastPostion = name.indexOf(char, lastPostion) + 1;
      if (lastPostion === 0) {
        return true;
      }
    });
  }

  function activeMatch(client) {
    let activeSearch = filter.active;
    if (activeSearch === 'any') {
      return true;
    }
    return activeSearch === client.active + '';
  }

  function matchAll(client) {
    return nameMatch(client) && activeMatch(client);
  }

  return _.filter(collection, matchAll);
}

var ClientsTable = React.createClass({
  getInitialState() {
    let clients = this.props.data;
    let search = { active: 'true', name: '' };
    let filteredClients = filterClients(clients, search);
    return { clients, search, filteredClients };
  },

  setSearch(search) {
    let filteredClients = filterClients(this.state.clients, search);
    this.setState({ filteredClients, search });
  },

  willReceiveProps(nextProps) {
    this.state.set({ clients: nextProps.data });
    this.setSearch(this.state.search);
  },

  searchName(event) {
    this.setSearch({
      name: event.target.value,
      active: this.state.search.active
    });
  },

  searchActive(event) {
    this.setSearch({
      name: this.state.search.name,
      active: event.target.value
    });
  },

  chooseName(e) {
    if (e.key !== 'Enter') { return; }
    let clients = this.state.filteredClients;
    if (clients.length === 1) {
      document.location.href = clients[0].links.view;
    }
  },

  search() {
    return (
      <div className="row collapse bakecycle-form">
        <div className="small-12 medium-4 columns">
          <div className="input string optional">
            <label className="string optional">Name</label>
            <input
              className="string optional"
              placeholder="Client Name"
              type="text"
              value={this.state.search.name}
              onChange={this.searchName}
              onKeyDown={this.chooseName}
              />
          </div>
        </div>
        <div className="small-12 medium-1 end columns">
          <div className="input string optional">
            <label className="string optional">Active?</label>
            <select value={this.state.search.active} onChange={this.searchActive}>
              <option value="true">Yes</option>
              <option value="false">No</option>
              <option value="any">Any</option>
            </select>
          </div>
        </div>
      </div>
    );
  },

  header() {
    return (
      <thead>
        <tr>
          <th scope="col">Name</th>
          <th scope="col">Active</th>
          <th scope="col">Actions</th>
        </tr>
      </thead>
    );
  },

  rows() {
    return this.state.filteredClients.map(function(client) {
      return (
        <tr className="js-clickable-row" href={client.links.view} key={client.id} >
          <th scope="row">
            <a href={client.links.view}>{client.name}</a>
          </th>
          <td data-title="Active">{client.active ? 'Yes' : 'No'}</td>
          <td data-title="Actions">
            <a href={client.links.edit}>
              <span className="table-action-icon icon-link-tooltip" aria-label="Edit Client">
                <i className="fi-page-edit"></i>
              </span>
            </a>
            <a href={client.links.view}>
              <span className="table-action-icon icon-link-tooltip" aria-label="View Client">
                <i className="fi-eye"></i>
              </span>
            </a>
            <a href={client.links.newOrder}>
              <span className="table-action-icon icon-link-tooltip" aria-label="Add Order For This Client">
                <i className="fi-page-add"></i>
              </span>
            </a>
          </td>
        </tr>
      );
    });
  },

  render() {
    return (<div>
      {this.search()}
      <table className="responsive-table">
        {this.header()}
        <tbody>
          {this.rows()}
        </tbody>
      </table>
    </div>);
  }
});

module.exports = ClientsTable;
